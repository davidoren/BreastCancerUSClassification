clc;
clear;
close all;
%%
InputDirectory = [cd '\BmodeRes'];
BmodePath = 'BmodeRes\';
BmodeOrigPath = '\Bmode\';
%%
% InputFiles = InputFiles(3:end);
InputFiles = dir([InputDirectory '\*.bmp']);
filenames = {InputFiles(:).name};
lesiontypes = cellfun('isempty',strfind(filenames,'.0'));

N = size(filenames, 2);

for i = 1:N
    current_image = LesionImg([BmodePath filenames{i}], [cd BmodeOrigPath]);
    Results(i, :) = current_image.get_features;
    
end