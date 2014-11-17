classdef LesionImg < handle
    properties
        orig_path;
        seg_path;
        im;
        im_seg;
        % Measures and Values
        area = 0;
        perimeter = 0;
        major_axis = 0;
        minor_axis = 0;
        centroid = [];
        pxl_values = [];
        polar_crd = [];
        % Images
        bounded_lesion = [];
        mask = [];
        bounded_mask = [];
        skewness = [];
        msrm = [];
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
        orig_path = GetOriginalFileName(seg_path)
    end
    methods
        function obj = LesionImg(seg_path, orig_path)
            obj.seg_path = seg_path;
            if nargin == 2
                obj.orig_path = orig_path;
            elseif nargin == 1
                obj.orig_path = GetOriginalFileName(obj.seg_path);
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
                obj.edge = im_double(:, :, 2) == 1 & im_double(:, :, 1) < 1 & im_double(:, :, 3) < 1;
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
        function bounded_mask = get.bounded_mask(obj)
            if size(obj.bounded_mask) == 0
                obj.bounded_mask = struct2array(regionprops(obj.mask, 'Image'));
            end
            bounded_mask = obj.bounded_mask;
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
        function bounded_lesion = get.bounded_lesion(obj)
            if size(obj.bounded_lesion) == 0
                im_gray(:, :) = obj.im(:, :, 1);
                bb = struct2array(regionprops(obj.mask, 'BoundingBox'));
                obj.bounded_lesion = zeros(size(obj.mask, 1), size(obj.mask, 2));
                obj.bounded_lesion(obj.bounded_mask) = im_gray(bb(2) : bb(4) - 1, bb(1) : bb(3) - 1);
            end
            bounded_lesion = obj.bounded_lesion;
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
        function features = get_features(obj)
            features = [obj.equiv_circle_ratio, obj.axes_ratio, ...
                obj.circularity, obj.convex_ratio, obj.eccentricity, ...
                obj.homogeneity, obj.light_ratio, obj.orientation, ...
                obj.ovalness_ellipse_ratio, obj.ovalness_lesion_ratio, ...
                obj.perimeter_area_ratio, obj.spiculation_low_freq_ratio, ...
                obj.spiculation_energy_compaction];
        end
    end
end