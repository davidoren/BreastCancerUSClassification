function output = LesionSpiculationByEnergyFraction(im)
F = abs(fft(LesionSortedPolarCoordinates(im)));
sz = size(F, 1);
output = sumsqr(F(1 : floor(sz/4))) ./ sumsqr(F(ceil(sz/4) : end));
end