function perim = LesionPerimeter(im)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
perim = max(struct2array(regionprops(LesionEdgeImage(im), 'Perimeter')));
% perim = perim.Perimeter;
end

