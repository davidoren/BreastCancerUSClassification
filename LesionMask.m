function output = LesionMask(im)
em = LesionEdgeImage(im);
% output = regionprops(em, 'FilledImage');
% output = output.FilledImage;
output = bwfill(em, 'holes', 8);

end