function im_filled = LesionFilledImage(im)
im_seg = LesionEdgeImage(im);
im_filled = regionprops(im_seg, 'FilledImage');
max_segment = 1;
max_segment_size = -Inf;
for i = 1 : size(im_filled, 1)
    sz = size(im_filled(i).FilledImage, 1) * size(im_filled(i).FilledImage, 2);
    if (sz > max_segment_size)
        max_segment = i;
        max_segment_size = sz;
    end
end
im_filled = im_filled(max_segment).FilledImage;
end