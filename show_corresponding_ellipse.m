InputDirectory = [cd '\bmode_img'];
BmodePath = 'bmode_img\';
%%
% InputDirectory = [cd '\original_images\b_mode_res'];
% BmodePath = 'original_images\b_mode_res\';
BmodeOrigPath = 'original_images\b_mode\';
%%
% InputFiles = InputFiles(3:end);
InputFiles = dir([InputDirectory '\*.bmp']);
filenames = {InputFiles(:).name};
if ~exist('i', 'var')
    i = 1;
end
im = imread([BmodePath filenames{i}], 'bmp');

com = struct2array(regionprops(LesionMask(im), 'Centroid'));
ellipse = draw_ellipse(com(2), com(1), LesionMajorAxis(im) ./ 2, ...
    LesionMinorAxis(im) ./ 2, -struct2array(regionprops(LesionMask(im), ...
    'Orientation')), zeros(size(im, 1), size(im, 2)), 255);
ellipse = im2bw(ellipse, 0.5);
figure;imshowpair(im, ellipse, 'montage');
overlap_area = max(struct2array(regionprops(ellipse & LesionMask(im), 'Area')))
overlap_perc_ellipse = overlap_area ./ bwarea(ellipse)
overlap_perc_lesion = overlap_area ./ LesionArea(im)