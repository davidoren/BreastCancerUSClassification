function output = LesionSkewnessImage(im, sz)
if size(size(im), 2) == 3
    img = im2double(rgb2gray(im));
else
    img = im;
end

fun = @(block) 1 ./ numel(block) .* sum( ((block(:) - mean(block(:))) ./ std(block(:))) .^ 3 );
output = nlfilter(img, sz, fun);
output = (output - mean(output(:))) ./ std(output(:));
imshow(output, []);
end