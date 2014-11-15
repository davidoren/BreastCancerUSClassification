function output = LesionPixelValues(im)
output = struct2array(regionprops(LesionMask(im), im(:, :, 1), 'PixelValues'));
end