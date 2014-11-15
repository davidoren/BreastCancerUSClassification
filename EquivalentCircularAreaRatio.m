function output = EquivalentCircularAreaRatio(im)
eq_circ_area = (LesionPerimeter(im) .^ 2) ./ (4 .* pi);
output = LesionArea(im) ./ eq_circ_area;
end