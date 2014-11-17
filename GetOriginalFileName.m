function orig_path = GetOriginalFileName(seg_path)
    ind = strfind(seg_path, '_1');
    orig_path = strcat(seg_path(1 : ind - 1), seg_path(ind + 2 : end));
end