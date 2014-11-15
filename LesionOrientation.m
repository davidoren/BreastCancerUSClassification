function output = LesionOrientation(im)
output = abs(struct2array(regionprops(LesionFilledImage(im), 'Orientation'))) ./ 90;
end