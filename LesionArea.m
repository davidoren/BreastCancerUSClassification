function area = LesionArea(im)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
area = max(struct2array(regionprops(LesionEdgeImage(im), 'FilledArea')));
% area = area.FilledArea;
end

