function varargout = verify(varargin)
% VERIFY MATLAB code for verify.fig
%      VERIFY, by itself, creates a new VERIFY or raises the existing
%      singleton*.
%
%      H = VERIFY returns the handle to a new VERIFY or the handle to
%      the existing singleton*.
%
%      VERIFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VERIFY.M with the given input arguments.
%
%      VERIFY('Property','Value',...) creates a new VERIFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before verify_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to verify_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help verify

% Last Modified by GUIDE v2.5 10-May-2017 17:56:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @verify_OpeningFcn, ...
                   'gui_OutputFcn',  @verify_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before verify is made visible.
function verify_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to verify (see VARARGIN)

% Choose default command line output for verify
handles.output = hObject;

handles.sect_rects = gobjects(1, 20);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes verify wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = verify_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in savebtn.
function savebtn_Callback(hObject, eventdata, handles)
char_index = handles.char_index;
file_index = handles.file_index;
file_index_max = handles.file_index_max;

if char_index >= 60
    savePosition(hObject, handles);
    if file_index < file_index_max
        handles.file_index = file_index+1;
        setView(hObject, handles);
        %save fileindex
        fileid = fopen(fullfile(handles.input_folder_name, 'config.txt'), 'w');
        fprintf(fileid, '%d', file_index+1);
        fclose(fileid);
    else
        set(handles.savebtn, 'Enable', 'off');
    end
else
    handles.char_index = char_index + 1;
    setCharView(hObject, handles);
end
handles = guidata(hObject);

guidata(hObject, handles);
   
% --- Executes on button press in input_folder_btn.
function input_folder_btn_Callback(hObject, eventdata, handles)
input_folder_name = uigetdir('C:\Users\E113\Documents\WORK\H_IM');
%stop if the user press cancel or close the dialog box
if input_folder_name == 0
    return;
end

%get folders from one parent folder
input_folders = cell(1, 5);
folders = {'0%', '20%', 'm20%', '40%', 'm40%' };
for t=1:5
    input_folders{t} = fullfile(input_folder_name, folders{t});
end

handles.input_folder_name = input_folder_name;
handles.input_folders = input_folders;

set(handles.input_folder_btn, 'Enable', 'off');

initView(hObject, handles);
handles = guidata(hObject);

% set(handles.output_folder_btn, 'Enable', 'on');
guidata(hObject, handles);

%function to initialize the parameters
function initView(hObject, handles)
%retrieve the files
for t=1:5
    src_im(t).Source = dir(strcat(handles.input_folders{t}, '\*bw.bmp'));
    src_pos(t).Source = dir(strcat(handles.input_folders{t}, '\*info.txt'));
end

%check whether the folders are valid
imcounter = length(src_im(1).Source);
poscounter = length(src_pos(1).Source);
if imcounter == 0 || poscounter == 0 || imcounter - poscounter ~= 0
    errordlg('# of im files and position files don''t match', 'error', 'modal');
    set(handles.input_folder_btn, 'Enable', 'on');
    return;
end

%get initial fileindex
fileid = fopen(fullfile(handles.input_folder_name, 'config.txt'), 'r');
if fileid == -1
   index = 1;
else
   index = fscanf(fileid, '%d');
   fclose(fileid);
end

if isnan(index) 
    index = 1;
end

%initialize some gui objects
handles.rects = gobjects(1,100);
handles.src_im = src_im;
handles.src_pos = src_pos;
handles.file_index_max = imcounter;
handles.file_index = index;
handles.section_index = 1;
handles.char_array_index = 1;

setView(hObject, handles);
handles = guidata(hObject);

set(handles.goto, 'Enable', 'on');
set(gcf,'KeyPressFcn',@keypressed_callback);

guidata(hObject, handles);

%function to display the images on the differents views
function setView(hObject, handles)
%display the image at file_index
set(handles.open_im, 'Enable', 'off');
index = handles.file_index;
section_index = handles.section_index;

%get the positions
if section_index == 1
    %get the 5 layers image
    input_im = struct('im', cell(1, 5));
    for t=1:5
        path = handles.src_im(t).Source(index);
        input_im(t).im = imread(fullfile(path.folder, path.name));
    end
    handles.input_im = input_im;
    [char_pos_raw(:,:,1), char_pos_raw(:,:,2), char_pos_raw(:,:,3)] = h_pos_raw(handles.src_pos, index);
    handles.char_pos_raw = char_pos_raw;
end

%build the image
[im, char_pos_final] = build_h_im(handles.input_im, handles.char_pos_raw(:,:,section_index), 10);
%plot to main_axes
handles.h_im = imagesc(im, 'Parent', handles.main_axes);
handles.h_im.HitTest = 'off';
handles.main_axes.HitTest = 'off';
char_pos(:,[1 2]) = char_pos_final(:,[1 2]) + 1.5;
char_pos(:,[3 4]) = char_pos_final(:,[3 4]) - 1.5;

axes(handles.main_axes)
temp = [char_pos(:,1), char_pos(:,2), abs(char_pos(:,1)-char_pos(:,3)), abs(char_pos(:,2)-char_pos(:,4)), char_pos_final(:,5)];
col = ['r', 'b', 'g', 'y', 'm'];
for t=1:100    
    handles.rects(t) = rectangle('Position', temp(t, 1:4), 'EdgeColor', col(1));
end
colormap gray;

%add page info to the guidata space
handles.char_pos_final = char_pos_final;
handles.im = im;


%update info displayed on the gui
section_counter_label = strcat(num2str(section_index), '/ 3');
counter = strcat(num2str(index), '/', num2str(handles.file_index_max));
set(handles.section_counter_label, 'String', section_counter_label);
set(handles.counter_label, 'String', counter);

%set callbacks
% set(handles.h_im, 'ButtonDownFcn',@adjustBox);
set(gcf, 'ButtonDownFcn',@main_axis_callback);

%set context menu
cm = uicontextmenu(gcf);

% Create child menu items for the uicontextmenu
m1 = uimenu(cm,'Label','Box adjustment','Callback',@adjustBox);
m2 = uimenu(cm,'Label','Noise removal','Callback',@eraseBox);
set(gcf, 'UIContextMenu', cm);
% m3 = uimenu(cm,'Label','Open image','Callback',@setlinestyle);
guidata(hObject, handles);

function setBox(rect_sec, rect_char, pos)
position = points2rect(pos);

rect_sec.Position = position;
rect_char.Position = position;

function setCharView(hObject, handles)
char_index = handles.char_index;
idx = mod(char_index-1, 20) + 1;
layer = floor((char_index-1)/20) + 1;

char_pos = handles.char_pos(idx,:, layer);
main_rect_pos = handles.main_rect_pos(layer,:);

if char_index == 21 || char_index == 41 || char_index == 20 || char_index == 40
    axes(handles.section_axes);
    section_pos = main_rect_pos(1, :); %first rectangle on the main axes
    xlim([section_pos(1) section_pos(3)+section_pos(1)-450]);
    ylim([section_pos(2) section_pos(2)+section_pos(4)-100]);
    drawrects(handles.section_axes, handles.sect_rects, handles.char_pos(:,:, layer));
end

%set limit on char view
axes(handles.char_axes);
posc = char_pos; % 1rst row, all col, 1rst layer
xlim([posc(1)-5 posc(3)+5]);
ylim([posc(2)-5 posc(4)+5]);


%set the position of the draggables on the main image
handles.main_rect.Position = main_rect_pos;
%set the position of the draggables on the section_view and char_view
setBox(handles.char_rect, handles.char_rect_focus, char_pos);

guidata(hObject, handles);

function drawrects(ax, rects, pos)
% handles = guidata(gcbo);
axes(ax);
for t=1:20
    rects(t).Position = points2rect(pos(t, :));
end

%save the position of the character in a file
function savePosition(filepath, anchor, pos)
pos = pos-1;

%get char unicode
c = strsplit(filepath, {'_', '.'});
deg = c{end-2};
uni3 = c{end-3};
uni2 = c{end-4};
uni1 = c{end-5};

idx = 1:8;
anchor = [idx' anchor]';

idx = 1:20;
pos1 = [idx' pos(:,:,1)]';
pos2 = [idx' pos(:,:,2)]';
pos3 = [idx' pos(:,:,3)]';

%output the positions to a file in the output folder
fileid = fopen(filepath, 'w');
fprintf(fileid, '%s\r\n', '[ Anchor Points ]');
fprintf(fileid, ' %d : (  %6.1f , %6.1f )\r\n', anchor);

fprintf(fileid, '\r\n[ Word Contours ] \r\n unicode_brightness: %s_%s \r\n', uni1, deg);
fprintf(fileid, ' %2d : ( %4d , %4d ) , ( %4d , %4d )\r\n', pos1);

fprintf(fileid, '\r\nunicode_brightness: %s_%s \r\n', uni2, deg);
fprintf(fileid, ' %2d : ( %4d , %4d ) , ( %4d , %4d )\r\n', pos2);

fprintf(fileid, '\r\nunicode_brightness: %s_%s \r\n', uni3, deg);
fprintf(fileid, ' %2d : ( %4d , %4d ) , ( %4d , %4d )\r\n', pos3);

fclose(fileid);

%callback for keypress
function keypressed_callback(hObject, eventdata)
handles = guidata(gcbo);

switch eventdata.Key
    case 'rightarrow'
        if handles.section_index == 3
            if handles.file_index ~= handles.file_index_max
                handles.file_index = handles.file_index + 1;
                handles.section_index = 1;
            end
        else
            handles.section_index = handles.section_index + 1;
        end
    case 'leftarrow'
        if handles.section_index == 1
            if handles.file_index ~= 1
                handles.file_index = handles.file_index - 1;
            end
        else
            handles.section_index = handles.section_index - 1;
        end
end

%save fileindex
fileid = fopen(fullfile(handles.input_folder_name, 'config.txt'), 'w');
fprintf(fileid, '%d',  handles.file_index);
fclose(fileid);
        
handles.char_array_index = 1;
setView(hObject, handles);
  
function position = points2rect(points)
points(1, [1 2]) = points(1, [1 2]) - 0.5;
points(1, [3 4]) = points(1, [3 4]) + 0.5;

%rectangular coodinates
position = [points(1) points(2) points(3)-points(1)  points(4)-points(2)];

function idx = closestRect(char_pos, point)
point = round(point);
row = size(char_pos, 1);
point = repmat(point, row, 1);

point = [point - char_pos(:,1:2), char_pos(:,3:4) - point];
point = point>=0;
point = sum(point, 2);
idx = find(point == 4);

function main_axis_callback(hObject, eventdata)
handles = guidata(hObject);
handles.rects(handles.char_array_index).EdgeColor = 'r';

point = get(handles.main_axes, 'CurrentPoint');
point = [point(1, 1) point(1, 2)];
idx = closestRect(handles.char_pos_final(:,1:4), point);

if isempty(idx)
    return;
end

handles.char_array_index = idx;
handles.rects(idx).EdgeColor = 'b';

show_char_info(hObject, handles); %display info of the current character
handles = guidata(hObject);

switch get(hObject,'SelectionType')
     case 'extend'
        adjustBox(hObject);
    case 'open'
        winopen(handles.edited_filename_im);
end
set(handles.open_im, 'Enable', 'on');
set(handles.open_im_color, 'Enable', 'on');
guidata(hObject, handles);

%TODO
%TRACK THE CHARACTER INFO BACK TO THE ORIGINAL FILES
function [x, y]  = swap(x1, y1)
x = y1;
y = x1;

% --- Executes during object creation, after setting all properties.
function pagenum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pagenum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in goto.
function goto_Callback(hObject, eventdata)
% hObject    handle to goto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

idx = get(handles.pagenum, 'String');
idx = str2double(idx);
if isnan(idx)
   idx=1; 
end

idx = round(idx);
if idx < 1
    idx = 1;
elseif idx > handles.file_index_max-1
    idx = handles.file_index_max-1;
end

handles.file_index = idx;
handles.section_index = 1;

%save fileindex
fileid = fopen(fullfile(handles.input_folder_name, 'config.txt'), 'w');
fprintf(fileid, '%d',  handles.file_index);
fclose(fileid);

setView(hObject, handles);

% --- Executes on key press with focus on pagenum and none of its controls.
function pagenum_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pagenum (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmp(eventdata.Key,'return')
        goto_Callback(verify, eventdata);
end

%============================IMAGE FACTORY=============================
function [im, char_pos_final] = build_h_im(orig_ima, char_pos_raw, padding)
%orig_ima 1x5 struct containing the images

%get the final positions
char_pos_final = h_pos_final(char_pos_raw, padding);

%build the images
%image1
row = max(char_pos_final(:,4));
col = max(char_pos_final(:,3));
im = ones(row, col);

%add the chars
for t=1:100
    %index for the input image
    in_x1 = char_pos_raw(t,1);
    in_y1 = char_pos_raw(t,2);
    in_x2 = char_pos_raw(t,3);
    in_y2 = char_pos_raw(t,4);
    brightness = char_pos_raw(t,8);
    
    %index for the ouput image
    out_x1 = char_pos_final(t,1);
    out_y1 = char_pos_final(t,2);
    out_x2 = char_pos_final(t,3);
    out_y2 = char_pos_final(t,4);
    
    %update the output image
    im(out_y1:out_y2, out_x1:out_x2) = orig_ima(brightness).im(in_y1:in_y2, in_x1:in_x2);
end

function char_pos = h_pos_final(raw_positions, padding)
char_pos = zeros(100,6);

point_start = [padding padding];
min_x = 10000;
for t=1:100
    pos = raw_positions(t,:);
    point_end = point_start + [pos(6) pos(7)];
    char_pos(t, :) = [point_start point_end pos(8) pos(9)];
    
    if t==19
        min_x = max(char_pos(1:t, 3));
    end
    %update the current points
%     if((mod(t,20) == 0) && t~=100) || point_end(1) > min_x
    if point_end(1) > min_x
        h = max(char_pos(1:t, 4));
        point_start(1) = padding;
        point_start(2) = h + padding;
    else
        point_start(1) = point_start(1) + pos(6) + padding;
    end
end

function [char1_pos, char2_pos, char3_pos] = h_pos_raw(src_pos, index)
%return Nx9 postition array
%char3_pos = [x1, y1, x2, y2, dist, width, heigth, brightnes, char_index];

%get the five position 
%im_pos(row, col, char, brightness)
for t=1:5
    pos = src_pos(t).Source(index);
    [~, im_pos(:,:,:,t)] = pointsFromFile(fullfile(pos.folder, pos.name));
end

%position array for each character
char1_pos = [im_pos(:,:,1,1); im_pos(:,:,1,2); im_pos(:,:,1,3); im_pos(:,:,1,4); im_pos(:,:,1,5)];
char2_pos = [im_pos(:,:,2,1); im_pos(:,:,2,2); im_pos(:,:,2,3); im_pos(:,:,2,4); im_pos(:,:,2,5)];
char3_pos = [im_pos(:,:,3,1); im_pos(:,:,3,2); im_pos(:,:,3,3); im_pos(:,:,3,4); im_pos(:,:,3,5)];

%add padding
char1_pos(:,[1 2]) = char1_pos(:,[1 2]) - 2;
char2_pos(:,[1 2]) = char2_pos(:,[1 2]) - 2;
char3_pos(:,[1 2]) = char3_pos(:,[1 2]) - 2;

char1_pos(:,[3 4]) = char1_pos(:,[3 4]) + 2;
char2_pos(:,[3 4]) = char2_pos(:,[3 4]) + 2;
char3_pos(:,[3 4]) = char3_pos(:,[3 4]) + 2;

%w, h, dist, brightness (br), char_index
br = [ones(20,1); ones(20,1)*2; ones(20,1)*3; ones(20,1)*4; ones(20,1)*5];
char_index = (1:20)';
char_index = [char_index; char_index; char_index; char_index; char_index];

w = abs(char1_pos(:,1) - char1_pos(:,3));
h = abs(char1_pos(:,2) - char1_pos(:,4));
dist = sqrt(w.^2 + h.^2);
char1_pos = [char1_pos, dist, w, h, br, char_index];

w = abs(char2_pos(:,1) - char2_pos(:,3));
h = abs(char2_pos(:,2) - char2_pos(:,4));
dist = sqrt(w.^2 + h.^2);
char2_pos = [char2_pos, dist, w, h, br, char_index];

w = abs(char3_pos(:,1) - char3_pos(:,3));
h = abs(char3_pos(:,2) - char3_pos(:,4));
dist = sqrt(w.^2 + h.^2);
char3_pos = [char3_pos, dist, w, h, br, char_index];

%sort the arrays by diagonal length oh the bounding boxes
char1_pos = sortrows(char1_pos,5);
char2_pos = sortrows(char2_pos,5);
char3_pos = sortrows(char3_pos,5);

function [anchor, char_pos] = pointsFromFile(filepath)
char_pos = zeros(20, 4, 3); % 3 layers position file

%extract the positions
fileid = fopen(filepath, 'r');

%anchor position
file = textscan(fileid, '%d %f %f', 8, 'HeaderLines', 1, 'Whitespace',' \b\t:(,)');
anchor = [file{1, 2} file{1, 3}];

%char1 position
file = textscan(fileid, '%d %d %d %d %d', 20, 'HeaderLines', 4, 'Whitespace',' \b\t:(,)');
char_pos(:,:,1) = [file{1, 2} file{1, 3} file{1, 4} file{1, 5}];

%char2 position
file = textscan(fileid, '%d %d %d %d %d', 20, 'HeaderLines', 3, 'Whitespace',' \b\t:(,)');
char_pos(:,:,2) = [file{1, 2} file{1, 3} file{1, 4} file{1, 5}];

%char3 position
file = textscan(fileid, '%d %d %d %d %d', 20, 'HeaderLines', 3, 'Whitespace',' \b\t:(,)');
char_pos(:,:,3) = [file{1, 2} file{1, 3} file{1, 4} file{1, 5}];

%add shift
char_pos = char_pos + 1;

fclose(fileid);

function loadChar(hObject, iserase)
handles = guidata(hObject);

%required data
final_char_index = handles.char_array_index; %index in pos_final
brightness = handles.char_pos_final(final_char_index,5);
section_index = handles.section_index;
raw_char_index = handles.char_pos_final(final_char_index, 6);

%get the position files
path = handles.src_pos(brightness).Source(handles.file_index);
fname = fullfile(path.folder, path.name);
handles.edited_filename_pos = fname;
[anchor, char_pos] = pointsFromFile(fname);

%image file name
path = handles.src_im(brightness).Source(handles.file_index);
fname = fullfile(path.folder, path.name);
handles.edited_filename_im = fname;

%colored image
handles.edited_filename_im_color = strcat(fname(1, 1:end-7), '.bmp');

%axis limit
limit = char_pos(raw_char_index,:,section_index);
x_limit = [limit(1)-2 limit(3)+2];
y_limit = [limit(2)-2 limit(4)+2];

%get the image file
handles.edited_im = handles.input_im(brightness).im;

if iserase
    figure, handles.edited_axes = imshow(handles.edited_filename_im_color);
else
    figure, handles.edited_axes = imagesc(handles.edited_im);
end

xlim(x_limit);
ylim(y_limit);
colormap gray;

%draw rectangle
pos1 = [limit(1) limit(2)]-0.5;
pos2 = [abs(limit(1)-limit(3)) abs(limit(2)-limit(4))] + 1;
handles.adjusted_rect = rectangle('Position', [pos1 pos2],'EdgeColor', 'r');

%update handles
handles.char_pos = char_pos;
handles.anchor = anchor;
handles.file_brightness = brightness;
guidata(gcf, handles);


%==================ADJUSTBOX=================
function adjustBox(hObject, evt)

loadChar(hObject, 0);
ax = gca;
ax.Title.String = 'Box Adjustment';

handles = guidata(gcf);
setappdata(gcf, 'handles', handles);

%set callback on the figure
set(gcf,'WindowButtonDownFcn',{@wbd, handles.adjusted_rect});
set(gcf,'CloseRequestFcn',{@app_close});

%wbd function
function wbd(hObject, eventdata, rect)

%==========char_pos===========
pos = rect.Position;
x1 = pos(1)+0.5;
y1 = pos(2)+0.5;
x2 = x1 + pos(3)-1;
y2 = y1 + pos(4)-1;
char_pos = [x1 y1 x2 y2];

cp = get(gca, 'CurrentPoint');
cp = [cp(1, 1) cp(1, 2)];
cp = round(cp);

temp1 = char_pos(1, [1 2]);
temp2 = char_pos(1, [3 4]);

d1 = sqrt(sum((temp1-cp).^2, 2));
d2 = sqrt(sum((temp2-cp).^2, 2));

if d1 > d2
    x = temp1(1);
    y = temp1(2);
else
    x = temp2(1);
    y = temp2(2);
end

set(gcf,'WindowButtonMotionFcn',{@wbm, x, y, rect})
set(gcf,'WindowButtonUpFcn',{@wbu})

%erase_wbm function
function wbm(h,evd, x, y, rect)
% executes while the mouse moves
points = get(gca, 'CurrentPoint');
points = [points(1, 1), points(1, 2)];
points = round(points);

if points(1) > x && points(2) > y
    [points(1), x] = swap(points(1), x);
    [points(2), y] = swap(points(2), y);
elseif points(2) > y
    [points(2), y] = swap(points(2), y);
elseif points(1) > x
    [points(1), x] = swap(points(1), x);
end

points = points-0.5;
x = x + 0.5;
y= y + 0.5;

rect.Position = [points abs(x-points(1)) abs(y-points(2))];

%erase_wbu function
function wbu(hObject,evd)
% executes when the mouse button is released
handles = getappdata(gcf, 'handles');

pos = handles.adjusted_rect.Position;
x1 = pos(1)+0.5;
y1 = pos(2)+0.5;
x2 = x1 + pos(3)-1;
y2 = y1 + pos(4)-1;

%update the position in char_pos
section_index = handles.section_index;
raw_char_index = handles.char_pos_final(handles.char_array_index, 6);
handles.char_pos(raw_char_index,:,section_index) = [x1 y1 x2 y2];

%save positions
savePosition(handles.edited_filename_pos, handles.anchor, handles.char_pos);

set(gcf,'WindowButtonMotionFcn','')
set(gcf,'WindowButtonUpFcn','')
setappdata(gcf, 'handles', handles);

function app_close(hObject,evd)
handles = getappdata(gcf, 'handles');
delete(gcf);
guidata(verify, handles);

%==================ERASE_BOX=================
function eraseBox(hObject, evt)
loadChar(hObject, 1);

ax = gca;
ax.Title.String = 'Noise Removal';

handles = guidata(gcf);
handles.erase_rect = rectangle('Position', [0 0 0 0 ], 'EdgeColor', 'b');

%file name
imfname = handles.edited_filename_im;

setappdata(gcf, 'handles', handles);

%set callback on the figure
set(gcf,'WindowButtonDownFcn',{@erase_wbd, handles.erase_rect, imfname});
set(gcf,'CloseRequestFcn',{@erase_close});

%erase_wbd function
function erase_wbd(hObject, eventdata, rect, imfname)
points = get(gca, 'CurrentPoint');
points = [points(1, 1), points(1, 2)];

x=round(points(1));
y=round(points(2));

set(gcf,'WindowButtonMotionFcn',{@erase_wbm, x, y, rect})
set(gcf,'WindowButtonUpFcn',{@erase_wbu, rect, imfname})

%erase_wbm function
function erase_wbm(h,evd, x, y, rect)
% executes while the mouse moves
points = get(gca, 'CurrentPoint');
points = [points(1, 1), points(1, 2)];
points = round(points);

if points(1) > x && points(2) > y
    [points(1), x] = swap(points(1), x);
    [points(2), y] = swap(points(2), y);
elseif points(2) > y
    [points(2), y] = swap(points(2), y);
elseif points(1) > x
    [points(1), x] = swap(points(1), x);
end

points = points-0.5;
x = x + 0.5;
y= y + 0.5;

rect.Position = [points abs(x-points(1)) abs(y-points(2))];

%erase_wbu function
function erase_wbu(hObject, evd, rect, imfname)
% executes when the mouse button is released
handles = getappdata(gcf, 'handles');

pos = rect.Position;
x1 = pos(1)+0.5;
y1 = pos(2)+0.5;
x2 = x1 + pos(3)-1;
y2 = y1 + pos(4)-1;

handles.edited_im(y1:y2, x1:x2) = 1;
handles.input_im(handles.file_brightness).im(y1:y2, x1:x2) = 1;
handles.edited_axes.CData(y1:y2, x1:x2, 1) = 255;
handles.edited_axes.CData(y1:y2, x1:x2, 2) = 255;
handles.edited_axes.CData(y1:y2, x1:x2, 3) = 255;

imwrite(handles.edited_axes.CData, handles.edited_filename_im_color);
imwrite(handles.edited_im, imfname);

%build the image
[im, ~] = build_h_im(handles.input_im, handles.char_pos_raw(:,:,handles.section_index), 10);
handles.h_im.CData = im;

set(gcf,'WindowButtonMotionFcn','')
set(gcf,'WindowButtonUpFcn','')

setappdata(gcf, 'handles', handles);

function erase_close(hObject,evd)
handles = getappdata(gcf, 'handles');
delete(gcf);
guidata(verify, handles);

function show_char_info(hObject, handles)

char_info = getCharInfo(handles);

if isempty(char_info)
    return;
end

br = {'0%', '20%', '-20%', '40%', '-40%'};

im_name = char_info{1}; 
pos_name = char_info{2}; 
brightness = br{char_info{3}};
section = char_info{4};
index = char_info{5};

%update info on gui
handles.im_name.String = im_name;
handles.pos_name.String = pos_name;
handles.brightness.String = brightness;
handles.section.String = num2str(section);
handles.index.String = num2str(index);

path = handles.src_im(char_info{3}).Source(handles.file_index);
fname = fullfile(path.folder, path.name);
handles.edited_filename_im = fname;
guidata(hObject, handles);

function char_info = getCharInfo(handles)
%return a cell in this order
%{im_name, pos_name, char_code, brightness, section, index}
point = get(handles.main_axes, 'CurrentPoint');
point = [point(1, 1) point(1, 2)];
idx = closestRect(handles.char_pos_final(:,1:4), point);

if isempty(idx)
    char_info = {};
    return;
end

char_info = cell(1, 6);

%required data
final_char_index = handles.char_array_index; %index in pos_final
char_info{3} = handles.char_pos_final(final_char_index,5); %brightness
char_info{4} = handles.section_index; %section
char_info{5} = handles.char_pos_final(final_char_index, 6); %index

%get the position files
path = handles.src_pos(char_info{3}).Source(handles.file_index);
% char_info{2} = fullfile(path.folder, path.name); %pos_name
char_info{2} = path.name; %pos_name

%image file name
path = handles.src_im(char_info{3}).Source(handles.file_index);
% char_info{1} = fullfile(path.folder, path.name); %im_name
char_info{1} = path.name; %im_name

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over open_im.
function open_im_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to open_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in open_im.
function open_im_Callback(hObject, eventdata, handles)
% hObject    handle to open_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
winopen(handles.edited_filename_im);

% --- Executes on button press in open_im_color.
function open_im_color_Callback(hObject, eventdata, handles)
% hObject    handle to open_im_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fname = handles.edited_filename_im;
fname = strcat(fname(1,1:end-7), '.bmp');
winopen(fname);
