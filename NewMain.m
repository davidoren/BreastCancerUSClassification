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
num_of_features = size(current_image.get_features, 2);
Results = zeros(size(lesiontypes, 2), num_of_features + 2);
for i = 1:N
    current_image = LesionImg([BmodePath filenames{i}], [cd BmodeOrigPath]);
    Results(i, 2 : end - 1) = current_image.get_features;
    Results(i, 1) = str2num(filenames{i}(1 : strfind(filenames{i}, '.') - 1));
    Results(i, end) = lesiontypes(i);
end
%%
% Construct a cell array with the titles and all results.
Output = cell(N + 1, size(current_image.titles, 2) + 2);
Output(1, 1) = {'Image No.'};
Output(1, 2 : end - 1) = current_image.titles;
Output(1, end) = {'Class'};
Output(2 : end, :) = num2cell(Results);

% Replacing all features that could not be extracted with a question mark.
for i = 1:numel(Output)
    if isequal(Output{i}, -Inf)
        Output{i} = '?';
    end
end

for i = 2:size(Output, 1)
    if isequal(Output{i, end}, 0)
        Output{i, end} = 'Benign';
    else
        Output{i, end} = 'Malignant';
    end
end
%%