function [page, section] = getCharId(dictio, chinese_char)
    idx = find(strcmp(dictio.words, chinese_char));

    if isempty(idx)
        page = [];
        section = [];
        return;
    end

    page = dictio.page(idx);
    section = dictio.section(idx);
end