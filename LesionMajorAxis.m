function maj_axis = LesionMajorAxis(im)
im_filled = LesionFilledImage(im);
maj_axis = regionprops(im_filled, 'MajorAxisLength');
maj_axis = maj_axis.MajorAxisLength;
end