function output = LesionLightenedAreaRatio(im)
% I = LesionImage(im);
I = LesionPixelValues(im);
bw = im2bw(I, graythresh(I));
output = sum(bw(:)) ./ LesionArea(im);

end