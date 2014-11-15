function [output, output_orig] = MultiScaleResponseMap(im, im_orig)
e = LesionEdgeImage(im);
im_orig_msrm = msrm(im_orig(:, :, 1), 8);
output(:, :, 1) = im_orig_msrm;
output(:, :, 3) = output(:, :, 1);
output(:, :, 2) = e + ~e .* im_orig_msrm;
output_orig = repmat(im_orig_msrm, 1, 1, 3);
end