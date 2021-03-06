classdef LesionImg < handle
    properties
        % General
        orig_path;
        seg_path;
        orig_dir;
        seg_dir;
        im;
        im_seg;
        num_of_features;
        titles = [];
        % Measures and Values
        area = 0;
        perimeter = 0;
        major_axis = 0;
        minor_axis = 0;
        lesion_height = 0;
        lesion_width = 0;
        centroid = [];
        pxl_values = [];
        polar_crd = [];
        bounded_box_crd = [];
        posterior_acoustic_parameters = [];
        posterior_acoustic_parameters_msrm = [];
        % Images
        bounded_lesion = [];
        bounded_msrm = [];
        mask = [];
        surround_mask = [];
        bounded_mask = [];
        skewness = [];
        msrm_image = [];
        edge = [];
        bounded_edge = [];
        ellipse = [];
        % Features
        equiv_circle_ratio = -1;
        axes_ratio = -1;
        circularity = -1;
        convex_ratio = -1;
        eccentricity = -1;
        homogeneity = -1;
        light_ratio = -1;
        orientation = -1;
        ovalness_ellipse_ratio = -1;
        ovalness_lesion_ratio = -1;
        perimeter_area_ratio = -1;
        spiculation_low_freq_ratio = -1;
        spiculation_energy_compaction = -1;
        posterior_shadowing = -Inf;
        posterior_enhancement = -Inf;
        posterior_no_pattern = -Inf;
        posterior_shadowing_msrm = -Inf;
        posterior_enhancement_msrm = -Inf;
        posterior_no_pattern_msrm = -Inf;
        texture_ratio = -1;
        texture_ratio_without_posterior = -1;
        boundary_variance_mean = -1;
        boundary_variance_median = -1;
        boundary_variance_lower_decile = -1;
%         bbox_width_height_ratio = -1;
%         avg_width = -1;
%         avg_height = -1;
%         max_width = -1;
%         max_height = -1;
%         measures = struct('area', 0, 'perimeter', 0, 'major_axis', 0,...
%             'minor_axis', 0, 'pxl_values', [], 'polar_crd', []);
%         images = struct('bounded_lesion', [], 'mask', [],...
%             'bounded_mask', [], 'skewness', [], 'msrm', [], 'edge', []);
%         features = struct('equiv_circle_ratio', -1, 'axes_ratio', -1,...
%             'circularity', -1, 'convex_ratio', -1, 'eccentricity', -1,...
%             'homogeneity', -1, 'light_ratio', -1, 'orientation', -1,...
%             'ovalness_ellipse_ratio', -1, 'ovalness_lesion_ratio', -1,...
%             'perimeter_area_ratio', -1, 'spiculation_low_freq_ratio',...
%             -1, 'spiculation_energy_compaction', -1);
    end
    methods(Static)
        orig_path = GetOriginalFileName(seg_path, orig_dir)
    end
    methods
        function obj = LesionImg(seg_path, orig_path)
            obj.seg_path = seg_path;
            if exist(orig_path, 'file') == 2
                obj.orig_path = orig_path;
            elseif exist(orig_path, 'dir') == 7
                obj.orig_path = GetOriginalFileName(obj.seg_path, orig_path);
            else
                error(message('Invalid number of arguments'))
            end
            if exist(obj.orig_path, 'file') && exist(obj.seg_path, 'file')
                obj.im = imread(obj.orig_path);
                obj.im_seg = imread(obj.seg_path);
            else
                return
            end
        end
        function img = get.edge(obj)
            if size(obj.edge) == 0
                im_double = im2double(obj.im_seg);
                obj.edge(:, :) = im_double(:, :, 2) == 1 & im_double(:, :, 1) < 1 & im_double(:, :, 3) < 1;
            end
            img = obj.edge;
        end
        function bounded_edge = get.bounded_edge(obj)
            if size(obj.bounded_edge) == 0
                obj.bounded_edge = struct2array(regionprops(obj.edge, 'Image'));
            end
            bounded_edge = obj.bounded_edge;
        end
        function area = get.area(obj)
            if obj.area == 0
                obj.area = max(struct2array(regionprops(obj.edge, 'FilledArea')));
            end
            area = obj.area;
        end
        function perim = get.perimeter(obj)
            if obj.perimeter == 0
                obj.perimeter = max(struct2array(regionprops(obj.edge, 'Perimeter')));
            end
            perim = obj.perimeter;
        end
        function majax = get.major_axis(obj)
            if obj.major_axis == 0
                obj.major_axis = struct2array(regionprops(obj.mask, 'MajorAxisLength'));
            end
            majax = obj.major_axis;
        end
        function minax = get.minor_axis(obj)
            if obj.minor_axis == 0
                obj.minor_axis = struct2array(regionprops(obj.mask, 'MinorAxisLength'));
            end
            minax = obj.minor_axis;
        end
        function height = get.lesion_height(obj)
            if obj.lesion_height == 0
                obj.lesion_height = size(obj.bounded_mask, 1);
            end
            height = obj.lesion_height;
        end
        function width = get.lesion_width(obj)
            if obj.lesion_width == 0
                obj.lesion_width = size(obj.bounded_mask, 2);
            end
            width = obj.lesion_width;
        end
        function com = get.centroid(obj)
            if size(obj.centroid) == 0
                obj.centroid = struct2array(regionprops(obj.mask, 'Centroid'));
            end
            com = obj.centroid;
        end
        function mask = get.mask(obj)
            if size(obj.mask) == 0
                obj.mask = bwfill(obj.edge, 'holes', 8);
            end
            mask = obj.mask;
        end
        function surround_mask = get.surround_mask(obj)
            if size(obj.surround_mask) == 0
                obj.surround_mask = xor(imdilate(obj.mask, strel('disk', 10)), obj.mask);
            end
            surround_mask = obj.surround_mask;
        end
        function bounded_mask = get.bounded_mask(obj)
            if size(obj.bounded_mask) == 0
                obj.bounded_mask = struct2array(regionprops(obj.mask, 'Image'));
            end
            bounded_mask = obj.bounded_mask;
        end
        function msrm_image = get.msrm_image(obj)
            if size(obj.msrm_image) == 0
                obj.msrm_image = msrm(obj.im(:, :, 1), 8);
            end
            msrm_image = obj.msrm_image;
        end
        function ellipse = get.ellipse(obj)
            if size(obj.ellipse) == 0
                maj_axis = obj.major_axis ./ 2; min_axis = obj.minor_axis ./ 2;
                orient = -struct2array(regionprops(obj.mask, 'Orientation'));
                el = draw_ellipse(obj.centroid(2), obj.centroid(1), maj_axis, ...
                    min_axis, orient, zeros(size(obj.im, 1), size(obj.im, 2)), 255);
                obj.ellipse = im2bw(el, 0.5);
            end
            ellipse = obj.ellipse;
        end
        function pxl_values = get.pxl_values(obj)
            if size(obj.pxl_values) == 0
                obj.pxl_values = struct2array(regionprops(obj.mask, obj.im(:, :, 1), 'PixelValues'));
            end
            pxl_values = obj.pxl_values;
        end
        function polar_crd = get.polar_crd(obj)
            if size(obj.polar_crd) == 0
                idx = regionprops(obj.bounded_edge, 'PixelList');
                com = regionprops(obj.bounded_edge, 'Centroid');
                crd = idx.PixelList - repmat(com.Centroid, size(idx.PixelList, 1), 1);
                [~, obj.polar_crd] = cart2pol(crd(:, 1), crd(:, 2));
            end
            polar_crd = obj.polar_crd;
        end
        function bounded_crd = get.bounded_box_crd(obj)
            if size(obj.bounded_box_crd) == 0
                obj.bounded_box_crd = floor(struct2array(regionprops(obj.mask, 'BoundingBox')));
            end
            bounded_crd = obj.bounded_box_crd;
        end
        function bounded_lesion = get.bounded_lesion(obj)
            if size(obj.bounded_lesion) == 0
                im_gray(:, :) = obj.im(:, :, 1);
                bb = obj.bounded_box_crd;
                obj.bounded_lesion = zeros(size(obj.bounded_mask, 1), size(obj.bounded_mask, 2), 'uint8');
                obj.bounded_lesion = im_gray(bb(2) : bb(2) + bb(4) - 1, bb(1) : bb(1) + bb(3) - 1);
                obj.bounded_lesion(~obj.bounded_mask) = 0;
            end
            bounded_lesion = obj.bounded_lesion;
        end
        function bounded_msrm = get.bounded_msrm(obj)
            if size(obj.bounded_msrm) == 0
                im_gray(:, :) = obj.msrm_image(:, :, 1);
                bb = obj.bounded_box_crd;
                obj.bounded_msrm = zeros(size(obj.bounded_mask, 1), size(obj.bounded_mask, 2), 'uint8');
                obj.bounded_msrm = im_gray(bb(2) : bb(2) + bb(4) - 1, bb(1) : bb(1) + bb(3) - 1);
                obj.bounded_msrm(~obj.bounded_mask) = 0;
            end
            bounded_msrm = obj.bounded_msrm;
        end
        function ratio = get.equiv_circle_ratio(obj)
            if obj.equiv_circle_ratio == -1
                obj.equiv_circle_ratio = obj.area ./ ((obj.perimeter .^ 2) ./ (4 .* pi));
            end
            ratio = obj.equiv_circle_ratio;
        end
        function axes_ratio = get.axes_ratio(obj)
            if obj.axes_ratio == -1
                obj.axes_ratio = obj.minor_axis ./ obj.major_axis;
            end
            axes_ratio = obj.axes_ratio;
        end
        function circ = get.circularity(obj)
            if obj.circularity == -1
                obj.circularity = std(obj.polar_crd ./ max(obj.polar_crd));
            end
            circ = obj.circularity;
        end
        function convex_ratio = get.convex_ratio(obj)
            if obj.convex_ratio == -1
                obj.convex_ratio = struct2array(regionprops(obj.bounded_mask, 'Solidity'));
            end
            convex_ratio = obj.convex_ratio;
        end
        function eccentricity = get.eccentricity(obj)
            if obj.eccentricity == -1
                obj.eccentricity = struct2array(regionprops(obj.bounded_mask, 'Eccentricity'));
            end
            eccentricity = obj.eccentricity;
        end
        function homogeneity = get.homogeneity(obj)
            if obj.homogeneity == -1
                v = 1 ./ 256 * ones(256, 1);
                max_extropy = - sum(v .* log2(v));
                obj.homogeneity = entropy(obj.pxl_values) ./ max_extropy;
            end
            homogeneity = obj.homogeneity;
        end
        function light_ratio = get.light_ratio(obj)
            if obj.light_ratio == -1
                bw = im2bw(obj.pxl_values, graythresh(obj.pxl_values));
                obj.light_ratio = sum(bw(:)) ./ obj.area;
            end
            light_ratio = obj.light_ratio;
        end
        function orientation = get.orientation(obj)
            if obj.orientation == -1
                obj.orientation = ...
                    abs(struct2array(regionprops(obj.bounded_mask, ...
                    'Orientation'))) ./ 90;
            end
            orientation = obj.orientation;
        end
        function ovalness_ellipse_ratio = get.ovalness_ellipse_ratio(obj)
            if obj.ovalness_ellipse_ratio == -1
                overlap_area = max(struct2array(regionprops(obj.ellipse ...
                    & obj.mask, 'Area')));
                obj.ovalness_ellipse_ratio = ...
                    overlap_area ./ bwarea(obj.ellipse);
            end
            ovalness_ellipse_ratio = obj.ovalness_ellipse_ratio;
        end
        function ovalness_lesion_ratio = get.ovalness_lesion_ratio(obj)
            if obj.ovalness_lesion_ratio == -1
                overlap_area = max(struct2array(regionprops(obj.ellipse ...
                    & obj.mask, 'Area')));
                obj.ovalness_lesion_ratio = ...
                    overlap_area ./ obj.area;
            end
            ovalness_lesion_ratio = obj.ovalness_lesion_ratio;
        end
        function perimeter_area_ratio = get.perimeter_area_ratio(obj)
            if obj.perimeter_area_ratio == -1
                obj.perimeter_area_ratio = obj.perimeter ./ obj.area;
            end
            perimeter_area_ratio = obj.perimeter_area_ratio;
        end
        function spiculation_low_freq_ratio = get.spiculation_low_freq_ratio(obj)
            if obj.spiculation_low_freq_ratio == -1
                F = fft(obj.polar_crd);
                sz = size(F, 1);
                obj.spiculation_low_freq_ratio = ...
                    trapz(abs(F(1 : round(sz/4)))) ./ ...
                    trapz(abs(F(round(sz/4) : end)));
            end
            spiculation_low_freq_ratio = obj.spiculation_low_freq_ratio;
        end
        function spiculation_energy_compaction = get.spiculation_energy_compaction(obj)
            if obj.spiculation_energy_compaction == -1
                F = abs(fft(obj.polar_crd));
                sz = size(F, 1);
                obj.spiculation_energy_compaction = ...
                    sumsqr(F(1 : floor(sz/4))) ./ ...
                    sumsqr(F(ceil(sz/4) : end));
            end
            spiculation_energy_compaction = obj.spiculation_energy_compaction;
        end
        function acoustic_parameters = get.posterior_acoustic_parameters(obj)
            effective_width = 1 ./ 2;
            effective_height = 2 ./ 3;
            sliding_window_width = 1 ./ 3 .* effective_width;
            if size(obj.posterior_acoustic_parameters) == 0
                if obj.bounded_box_crd(2) + ceil((1 + effective_height) * obj.lesion_height) - 1 > size(obj.im, 1) || ...
                        obj.bounded_box_crd(1) - ceil(effective_width * obj.lesion_width) < 1 || ...
                        obj.bounded_box_crd(1) + ceil((1 + effective_width) .* obj.lesion_width) - 1 > size(obj.im, 2)
                    obj.posterior_acoustic_parameters = [];
                else
                    L_upper = obj.bounded_box_crd(2) + obj.lesion_height;
                    L_bottom = L_upper + ceil(effective_height .* obj.lesion_height);
                    L_left = obj.bounded_box_crd(1) - ceil(effective_width .* obj.lesion_width);
                    L_right = obj.bounded_box_crd(1) - 1;
                    R_upper = L_upper;
                    R_bottom = L_bottom;
                    R_left = obj.bounded_box_crd(1) + obj.lesion_width;
                    R_right = R_left + ceil(effective_width .* obj.lesion_width) - 1;
                    P_upper = L_upper;
                    P_bottom = L_bottom;
                    P_left = L_right + round(1 ./ 6 * obj.lesion_width);
                    P_right = R_left - round(1 ./ 6 * obj.lesion_width);
                    L_img(:, :) = obj.im(L_upper : L_bottom, L_left : L_right, 1);
                    R_img(:, :) = obj.im(R_upper : R_bottom, R_left : R_right, 1);
                    P_img(:, :) = obj.im(P_upper : P_bottom, P_left : P_right, 1);
                    L_avg = mean(L_img(:));
                    R_avg = mean(R_img(:));
                    P_avg = mean(P_img(:));
                    P_slide_left = P_left; P_slide_right = P_slide_left + ceil(sliding_window_width .* obj.lesion_width);
                    P_sliding = obj.im(P_upper : P_bottom, P_slide_left : P_slide_right, 1);
                    P_min = mean(P_sliding(:));
                    P_max = P_min;
                    while P_slide_right <= P_right
                        P_slide_left = P_slide_left + 1;
                        P_slide_right = P_slide_right + 1;
                        P_sliding = obj.im(P_upper : P_bottom, P_slide_left : P_slide_right, 1);
                        P_sliding_avg = mean(P_sliding(:));
                        if P_sliding_avg > P_max
                            P_max = P_sliding_avg;
                        elseif P_sliding_avg < P_min
                            P_min = P_sliding_avg;
                        end
                    end
                    obj.posterior_acoustic_parameters = [L_avg, R_avg, P_avg, P_min, P_max];
                end
            end
            acoustic_parameters = obj.posterior_acoustic_parameters;
        end
        function acoustic_parameters = get.posterior_acoustic_parameters_msrm(obj)
            effective_width = 1 ./ 2;
            effective_height = 2 ./ 3;
            sliding_window_width = 1 ./ 3 .* effective_width;
            if size(obj.posterior_acoustic_parameters_msrm) == 0
                if obj.bounded_box_crd(2) + ceil((1 + effective_height) * obj.lesion_height) - 1 > size(obj.im, 1) || ...
                        obj.bounded_box_crd(1) - ceil(effective_width * obj.lesion_width) < 1 || ...
                        obj.bounded_box_crd(1) + ceil((1 + effective_width) .* obj.lesion_width) - 1 > size(obj.im, 2)
                    obj.posterior_acoustic_parameters_msrm = [];
                else
                    L_upper = obj.bounded_box_crd(2) + obj.lesion_height;
                    L_bottom = L_upper + ceil(effective_height .* obj.lesion_height);
                    L_left = obj.bounded_box_crd(1) - ceil(effective_width .* obj.lesion_width);
                    L_right = obj.bounded_box_crd(1) - 1;
                    R_upper = L_upper;
                    R_bottom = L_bottom;
                    R_left = obj.bounded_box_crd(1) + obj.lesion_width;
                    R_right = R_left + ceil(effective_width .* obj.lesion_width) - 1;
                    P_upper = L_upper;
                    P_bottom = L_bottom;
                    P_left = L_right + round(1 ./ 6 * obj.lesion_width);
                    P_right = R_left - round(1 ./ 6 * obj.lesion_width);
                    L_img(:, :) = obj.msrm_image(L_upper : L_bottom, L_left : L_right, 1);
                    R_img(:, :) = obj.msrm_image(R_upper : R_bottom, R_left : R_right, 1);
                    P_img(:, :) = obj.msrm_image(P_upper : P_bottom, P_left : P_right, 1);
                    L_avg = mean(L_img(:));
                    R_avg = mean(R_img(:));
                    P_avg = mean(P_img(:));
                    P_slide_left = P_left; P_slide_right = P_slide_left + ceil(sliding_window_width .* obj.lesion_width);
                    P_sliding = obj.msrm_image(P_upper : P_bottom, P_slide_left : P_slide_right, 1);
                    P_min = mean(P_sliding(:));
                    P_max = P_min;
                    while P_slide_right <= P_right
                        P_slide_left = P_slide_left + 1;
                        P_slide_right = P_slide_right + 1;
                        P_sliding = obj.im(P_upper : P_bottom, P_slide_left : P_slide_right, 1);
                        P_sliding_avg = mean(P_sliding(:));
                        if P_sliding_avg > P_max
                            P_max = P_sliding_avg;
                        elseif P_sliding_avg < P_min
                            P_min = P_sliding_avg;
                        end
                    end
                    obj.posterior_acoustic_parameters_msrm = [L_avg, R_avg, P_avg, P_min, P_max];
                end
            end
            acoustic_parameters = obj.posterior_acoustic_parameters_msrm;
        end
        function posterior_shadowing = get.posterior_shadowing(obj)
            if obj.posterior_shadowing == -Inf
                if size(obj.posterior_acoustic_parameters) == 0
                    obj.posterior_shadowing = -Inf;
                else
                    params = obj.posterior_acoustic_parameters;
                    obj.posterior_shadowing = min(params(1), params(2)) - params(5);
                end
            end
            posterior_shadowing = obj.posterior_shadowing;
        end
        function posterior_enhancement = get.posterior_enhancement(obj)
            if obj.posterior_enhancement == -Inf
                if size(obj.posterior_acoustic_parameters) == 0
                    obj.posterior_enhancement = -Inf;
                else
                    params = obj.posterior_acoustic_parameters;
                    obj.posterior_enhancement = params(4) - max(params(1), params(2));
                end
            end
            posterior_enhancement = obj.posterior_enhancement;
        end
        function posterior_no_pattern = get.posterior_no_pattern(obj)
            if obj.posterior_no_pattern == -Inf
                if size(obj.posterior_acoustic_parameters) == 0
                    obj.posterior_no_pattern = -Inf;
                else
                    params = obj.posterior_acoustic_parameters;
                    obj.posterior_no_pattern = min(abs(params(1) - params(3)), abs(params(2) - params(3)));
                end
            end
            posterior_no_pattern = obj.posterior_no_pattern;
        end
        function posterior_shadowing = get.posterior_shadowing_msrm(obj)
            if obj.posterior_shadowing_msrm == -Inf
                if size(obj.posterior_acoustic_parameters_msrm) == 0
                    obj.posterior_shadowing_msrm = -Inf;
                else
                    params = obj.posterior_acoustic_parameters_msrm;
                    obj.posterior_shadowing_msrm = min(params(1), params(2)) - params(5);
                end
            end
            posterior_shadowing = obj.posterior_shadowing_msrm;
        end
        function posterior_enhancement = get.posterior_enhancement_msrm(obj)
            if obj.posterior_enhancement_msrm == -Inf
                if size(obj.posterior_acoustic_parameters_msrm) == 0
                    obj.posterior_enhancement_msrm = -Inf;
                else
                    params = obj.posterior_acoustic_parameters_msrm;
                    obj.posterior_enhancement_msrm = params(4) - max(params(1), params(2));
                end
            end
            posterior_enhancement = obj.posterior_enhancement_msrm;
        end
        function posterior_no_pattern = get.posterior_no_pattern_msrm(obj)
            if obj.posterior_no_pattern_msrm == -Inf
                if size(obj.posterior_acoustic_parameters_msrm) == 0
                    obj.posterior_no_pattern_msrm = -Inf;
                else
                    params = obj.posterior_acoustic_parameters_msrm;
                    obj.posterior_no_pattern_msrm = min(abs(params(1) - params(3)), abs(params(2) - params(3)));
                end
            end
            posterior_no_pattern = obj.posterior_no_pattern_msrm;
        end
        function texture_ratio = get.texture_ratio(obj)
            if obj.texture_ratio == -1
                msrm_values = obj.msrm_image(obj.mask);
                msrm_mean = mean(msrm_values(:));
                surround_values = obj.msrm_image(obj.surround_mask);
                surround_mean = mean(surround_values(:));
                obj.texture_ratio = msrm_mean ./ surround_mean;
            end
            texture_ratio = obj.texture_ratio;
        end
        function texture_ratio_without_posterior = get.texture_ratio_without_posterior(obj)
            if obj.texture_ratio_without_posterior == -1
                R = 10;
                msrm_values = obj.msrm_image(obj.mask);
                msrm_mean = mean(msrm_values(:));
                [xx, yy] = meshgrid(-R : R);
                nhood = and(xx .^ 2 + yy .^ 2 <= R ^ 2, yy < 0);
                sur_mask = xor(imdilate(obj.mask, strel(nhood)), obj.mask);
                surround_values = obj.msrm_image(sur_mask);
                surround_mean = mean(surround_values(:));
                obj.texture_ratio_without_posterior = msrm_mean ./ surround_mean;
            end
            texture_ratio_without_posterior = obj.texture_ratio_without_posterior;
        end
        function boundary_variance_mean = get.boundary_variance_mean(obj)
            if obj.boundary_variance == -1
                R = 4;
                element = strel('disk', R);
                nhood = element.getnhood;
                nhoodheight = size(nhood, 1);
                nhoodwidth = size(nhood, 2);
                crd = struct2array(regionprops(obj.edge, 'PixelList'));
                crd = crd(crd(:, 1) - floor(nhoodwidth ./ 2) > 0, :);
                crd = crd(crd(:, 1) + floor(nhoodwidth ./ 2) <= size(obj.im, 2), :);
                crd = crd(crd(:, 2) - floor(nhoodheight ./ 2) > 0, :);
                crd = crd(crd(:, 2) + floor(nhoodheight ./ 2) <= size(obj.im, 1), :);
                variance = zeros(size(crd, 1), 1);
%                 curr_mask = false(size(obj.edge, 1), size(obj.edge, 2));  
                for i = 1:size(crd, 1)
                    values = obj.im(crd(i, 2) - floor(nhoodheight ./ 2) : ...
                        crd(i, 2) + floor(nhoodheight ./ 2), ...
                        crd(i, 1) - floor(nhoodwidth ./ 2) : ...
                        crd(i, 1) + floor(nhoodwidth ./ 2), 1);
                    nhood_values = values(nhood(:));
                    variance(i) = var(double(nhood_values));
                end
                obj.boundary_variance_mean = mean(variance);
                obj.boundary_variance_median = median(variance);
                obj.boundary_variance_lower_decile = prctile(variance, 10);
            end
            boundary_variance_mean = obj.boundary_variance;
        end
        function boundary_median = get.boundary_variance_median(obj)
            if obj.boundary_variance_median == -1
                obj.boundary_variance_mean;
            end
            boundary_median = obj.boundary_variance_median;
        end
        function boundary_decile = get.boundary_variance_lower_decile(obj)
            if obj.boundary_variance_lower_decile == -1
                obj.boundary_variance_mean;
            end
            boundary_decile = obj.boundary_variance_lower_decile;
        end
%         function bbox_width_height_ratio = get.bbox_width_height_ratio(obj)
%             if obj.bbox_width_height_ratio == -1
%                 obj.bbox_width_height_ratio = obj.bounded_box_crd(3) ./ obj.bounded_box_crd(4);
%             end
%             bbox_width_height_ratio = obj.bbox_width_height_ratio;
%         end
%         function avg_width = get.avg_width(obj)
%             if obj.avg_width == -1
%                 obj.avg_width = obj.area ./ obj.bounded_box_crd(4);
%             end
%             avg_width = obj.avg_width;
%         end
%         function avg_height = get.avg_height(obj)
%             if obj.avg_height == -1
%                 obj.avg_height = obj.area ./ obj.bounded_box_crd(3);
%             end
%             avg_height = obj.avg_height;
%         end
%         function max_width = get.max_width(obj)
%             if obj.max_width == -1
%                 crd = 
%             end
%             max_width = obj.max_width;
%         end
%         function max_height = get.max_height(obj)
%             if obj.max_height == -1
%                 
%             end
%             max_height = obj.max_height;
%         end
        function features = get_features(obj)
            features = [obj.equiv_circle_ratio, obj.axes_ratio, ...
                obj.circularity, obj.convex_ratio, obj.eccentricity, ...
                obj.homogeneity, obj.light_ratio, obj.orientation, ...
                obj.ovalness_ellipse_ratio, obj.ovalness_lesion_ratio, ...
                obj.perimeter_area_ratio, obj.spiculation_low_freq_ratio, ...
                obj.spiculation_energy_compaction, obj.posterior_shadowing, ...
                obj.posterior_enhancement, obj.posterior_no_pattern, ...
                obj.posterior_shadowing_msrm, obj.posterior_enhancement_msrm, ...
                obj.posterior_no_pattern_msrm, obj.texture_ratio, ...
                obj.texture_ratio_without_posterior, obj.boundary_variance];
        end
        function num_features = get.num_of_features(obj)
            num_features = size(obj.get_features, 2);
        end
        function titles = get.titles(obj)
            if size(obj.titles) == 0
                props = properties(obj);
                obj.titles = props(end - obj.num_of_features + 1 : end)';
            end
            titles = obj.titles;
        end
        function sz = get_size(obj)
            props = properties(obj);
            sz = 0;
            for ii = 1:length(props)
                currentProperty = getfield(obj, char(props(ii)));
                s = whos('currentProperty');
                sz = sz + s.bytes;
            end
        end
    end
end