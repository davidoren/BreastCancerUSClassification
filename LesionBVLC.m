function bvlc = LesionBVLC(im)
ro_vector = [ro(im, 0, 1), ro(im, 1, 0), ro(im, 1, 1), ro(im, 1, -1)];
bvlc = max(ro_vector) - min(ro_vector);
end

function r = ro(im, k, l)
lesion_image = double(LesionImage(im));
lesion_pixel_values = LesionPixelValues(im);
shifted_image = ShiftMat(lesion_image, k, l);
corr_kl = lesion_image .* shifted_image;
r = 1 / LesionArea(im) * sum(corr_kl(:)) .* mean(lesion_pixel_values) .* mean(shifted_image(:)) ./ std(lesion_pixel_values) ./ std(shifted_image(:));
end

function shifted = ShiftMat(A, x, y)
[m, n] = size(A);
% shifted = zeros(size(A));
if x > 0
    shifted = [zeros(m, x), A(:, 1 : n - x)];
elseif x < 0
    x = abs(x);
    shifted = [A(:, x + 1 : end), zeros(m, x)];
end
if y > 0
    shifted = [zeros(y, n); A(1 : m - y, :)];
elseif y < 0
    y = abs(y);
    shifted = [A(y + 1 : end, :); zeros(y, n)];
end
end