function output = LesionSpiculation(im)
F = fft(LesionSortedPolarCoordinates(im));
sz = size(F, 1);
output = trapz(abs(F(1 : round(sz/4)))) ./ trapz(abs(F(round(sz/4) : end)));
end