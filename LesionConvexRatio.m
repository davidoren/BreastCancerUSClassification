function convex_ratio = LesionConvexRatio(im)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
convex_ratio = regionprops(LesionFilledImage(im), 'Solidity');
convex_ratio = convex_ratio.Solidity;
end

