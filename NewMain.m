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
current_image = LesionImg([BmodePath filenames{1}], [cd BmodeOrigPath]);
Results = zeros(size(lesiontypes, 2), size(current_image.get_features, 2) + 2);
for i = 1:N
    current_image = LesionImg([BmodePath filenames{i}], [cd BmodeOrigPath]);
    Results(i, 2 : end - 1) = current_image.get_features;
    Results(i, 1) = str2num(filenames{i}(1 : strfind(filenames{i}, '.') - 1));
    Results(i, end) = lesiontypes(i);
end