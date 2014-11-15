function axes_ratio = LesionAxesRatio(im)
axes_ratio = LesionMinorAxis(im) ./ LesionMajorAxis(im);
end