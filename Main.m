clc;
clear;
close all;

%% 
% InputDirectory = [cd '\bmode_img'];
% BmodePath = 'bmode_img\';
%%
InputDirectory = [cd '\original_images\b_mode_res'];
BmodePath = 'original_images\b_mode_res\';
BmodeOrigPath = 'original_images\b_mode\';
%%
% InputFiles = InputFiles(3:end);
InputFiles = dir([InputDirectory '\*.bmp']);
filenames = {InputFiles(:).name};
lesiontypes = cellfun('isempty',strfind(filenames,'.0'));
% Results = cell(size(filenames));

N = size(filenames, 2);

for i = 1:N
    im = imread([BmodePath filenames{i}], 'bmp');
    s = filenames{i};
    ind = strfind(s, '_1');
    orig_filename = strcat(s(1 : ind - 1), s(ind + 2 : end));
    if exist([BmodeOrigPath orig_filename], 'file')
        im_orig = imread([BmodeOrigPath orig_filename], 'bmp');
    else
        im_orig = LesionEdgeRestored(im);
    end
    [im_msrm, im_orig_msrm]= MultiScaleResponseMap(im, im_orig);
%     im_orig = repmat(msrm(im_orig(:, :, 1), 8), 1, 1, 3);
%     Results(i) = struct();
    Results(i).FileName = filenames{i};
    Results(i).AxesRatio = LesionAxesRatio(im);
    Results(i).ConvexRatio = LesionConvexRatio(im);
    Results(i).Eccentricity = LesionEccentricity(im);
    Results(i).PerimeterAreaRatio = LesionPerimeterAreaRatio(im);
    Results(i).EdgeAverageGradient = LesionBoundaryAverageGradient(im_msrm, im_orig_msrm);
    Results(i).LightenedAreaRatio = LesionLightenedAreaRatio(im_msrm);
    Results(i).EquivalentCircularAreaRatio = EquivalentCircularAreaRatio(im);
    Results(i).BDIP = LesionBDIP(im_msrm); % Block difference of inverse probabilities
    Results(i).BVLC = LesionBVLC(im_msrm); % Block variation of local correlation coefficients
    Results(i).Spiculation = LesionSpiculation(im);
    Results(i).Circularity = LesionCircularity(im);
    Results(i).Homogeneity = LesionHomogeneity(im2uint8(im_msrm));
    Results(i).Orientation = LesionOrientation(im);
    Results(i).OvalnessByLesion = LesionOvalnessByLesionRatio(im);
    Results(i).OvalnessByEllipse = LesionOvalnessByEllipseRatio(im);
    Results(i).type = lesiontypes(i);
end
titles = fieldnames(Results);
finalRes = [titles squeeze(struct2cell(Results))]';