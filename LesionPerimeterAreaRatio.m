function perim_area_ratio = LesionPerimeterAreaRatio(im)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
perim_area_ratio = LesionPerimeter(im) ./ LesionArea(im);
end

