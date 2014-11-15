function min_axis = LesionMinorAxis(im)
im_filled = LesionFilledImage(im);
min_axis = regionprops(im_filled, 'MinorAxisLength');
min_axis = min_axis.MinorAxisLength;
end