% Based on:
% P.S.Rodrigues,A new methodology based on q-entropy for breast lesion
% classification in 3-D ultrasound images,in : Proceedings of the 28th IEEE EMBS
% Annual International Conference,2006,pp.1048–1051.

function output = LesionHomogeneity(im)
% values = struct2array(regionprops(LesionMask(im), im(:, :, 1), 'PixelValues'));
values = LesionPixelValues(im);
v = 1 ./ 256 * ones(256, 1);
max_extropy = - sum(v .* log2(v));
output = entropy(values) ./ max_extropy;

end