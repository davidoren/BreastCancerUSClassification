function orig_path = GetOriginalFileName(seg_path, orig_dir)
    if strcmp(orig_dir(end), '\\')
        dirname = orig_dir(1 : end - 1);
    else
        dirname = orig_dir(1 : end);
    end
    filename = strsplit(seg_path, '\\');
    filename = filename{end};
    ind = strfind(filename, '_1');
    orig_path = [dirname '\\' strcat(filename(1 : ind - 1), filename(ind + 2 : end))];
end