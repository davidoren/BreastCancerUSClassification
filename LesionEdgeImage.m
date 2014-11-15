function im_edge = LesionEdgeImage(im)
im_double = im2double(im);
im_edge = im_double(:, :, 2) == 1 & im_double(:, :, 1) < 1 & im_double(:, :, 3) < 1;
end