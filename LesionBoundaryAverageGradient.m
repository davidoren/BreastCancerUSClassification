function avg_grad = LesionBoundaryAverageGradient(im, im_orig)
% im_restored = LesionEdgeRestored(im);
[G, ~] = imgradient(im_orig(:, :, 1));
avg_grad = mean(G(LesionEdgeImage(im)));
end