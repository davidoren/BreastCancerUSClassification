function output = LesionOvalnessByLesionRatio(im)
lesion_mask = LesionMask(im);
maj_axis = LesionMajorAxis(im) ./ 2;
min_axis = LesionMinorAxis(im) ./ 2;
orientation = -struct2array(regionprops(LesionMask(im), 'Orientation'));
com = struct2array(regionprops(lesion_mask, 'Centroid'));
ellipse = draw_ellipse(com(2), com(1), maj_axis, ...
    min_axis, orientation, zeros(size(im, 1), size(im, 2)), 255);
ellipse = im2bw(ellipse, 0.5);
overlap_area = max(struct2array(regionprops(ellipse & LesionMask(im), ...
    'Area')));
output = overlap_area ./ LesionArea(im);
end