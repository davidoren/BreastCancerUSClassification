function output = LesionEdgeRestored(im)
r(:, :) = im(:, :, 1);
g(:, :) = im(:, :, 2);
e = g == 255;
r_mean = r;
r_mean(g == 255) = uint8(mean(mean(r)));
rmed = medfilt2(r, [3 3]);
r_new = uint8(e) .* rmed + uint8(1-e) .* r_mean;

output(:, :, 1) = r_new;
output(:, :, 2) = r_new;
output(:, :, 3) = r_new;
end