function output = LesionImage(im)
e = LesionEdgeImage(im);
filled = imfill(e, 'holes');
filled(e) = false;
% output(:, :, 1) = uint8(filled) .* im(:, :, 1);
% output(:, :, 2) = uint8(filled) .* im(:, :, 2);
% output(:, :, 3) = uint8(filled) .* im(:, :, 3);
% output(:, :) = uint8(filled) .* im(:, :, 3);
output(:, :) = uint8(filled) .* im(:, :, 3);
% output(output == 255) = 0;
[row, col] = find(filled ~= 0);
output = output(min(row) : max(row), min(col) : max(col), :);
end