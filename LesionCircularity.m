% Based on:
% P.S.Rodrigues,A new methodology based on q-entropy for breast lesion
% classification in 3-D ultrasound images,in : Proceedings of the 28th IEEE EMBS
% Annual International Conference,2006,pp.1048–1051.

function output = LesionCircularity(im)
crd = LesionSortedPolarCoordinates(im);
crd = crd ./ max(crd);
output = std(crd);
end