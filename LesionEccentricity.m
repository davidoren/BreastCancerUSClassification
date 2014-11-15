function ecc = LesionEccentricity(im)
ecc = regionprops(LesionFilledImage(im), 'Eccentricity');
ecc = ecc.Eccentricity;
end