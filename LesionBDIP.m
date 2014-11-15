function bdip = LesionBDIP(im)
lesion_image = LesionPixelValues(im);
bdip = LesionArea(im) - double(sum(lesion_image)) ./ double(max(lesion_image));
bdip = bdip ./ LesionArea(im);
end