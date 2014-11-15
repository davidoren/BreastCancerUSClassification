function output = LesionSortedPolarCoordinates(im)
em = regionprops(LesionEdgeImage(im), 'Image');
idx = regionprops(em.Image, 'PixelList');
centroid = regionprops(em.Image, 'Centroid');
crd = idx.PixelList - repmat(centroid.Centroid, size(idx.PixelList, 1), 1);
[th, ro] = cart2pol(crd(:, 1), crd(:, 2));
% crd_sort = sortrows([th, ro], 1);
% output = crd_sort(:, 2);
output = ro;
end