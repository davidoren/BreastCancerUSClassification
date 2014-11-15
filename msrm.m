function M = msrm(im, N)
if nargin == 1
    N = 8;
end
[m, n] = size(im); % Dimensions of the image
im_double = im2double(im);
% im_double = im;
lambda = 2; % According to Lang (2013), the best results were achieved with this value for lambda
R_c = [3, 5, 7, 10, 12, 15, 18, 20]; % Vector of diameters of the center region of the receptive field
S_c = R_c .^ 2; % Support of the receptive fields center regions
R_s = 2 * R_c; % Diameters of the surround region of the receptive fields
S_s = R_s .^ 2 - S_c; % Support of the receptive fields surround regions
f_c = cell(1, N); % Gaussian kernels for center regions
f_s = cell(1, N); % Gaussian kernels for surround regions
L_c = zeros(m, n, N); % The image smoothed with the differrent center region Gaussian kernels
L_s = zeros(m, n, N); % The image smoothed with the differrent surround region Gaussian kernels
L = zeros(m, n, N); % The difference of Gaussians for each resolution

% Initializing the center & surround kernels
for i = 1:N
    f_c{i} = fspecial('gaussian', sqrt(S_c(i)), R_c(i)); 
end

for i = 1:N
    gauss_filter = fspecial('gaussian', sqrt(S_s(i) + S_c(i)), R_s(i));
    gauss_filter(floor(R_s(i)/2 - R_c(i)/2 + 1 : R_s(i)/2 + R_c(i)/2), floor(R_s(i)/2 - R_c(i)/2 + 1 : R_s(i)/2 + R_c(i)/2)) = 0;
    f_s{i} = gauss_filter;
end

% Smoothing the image with center & surround region resolutions
for i = 1:N
    L_c(:, :, i) = imfilter(im_double, f_c{i}, 'same');
end

for i = 1:N
    L_s(:, :, i) = imfilter(im_double, f_s{i}, 'same');
end

% Difference of Gaussians
for i = 1:N
    L(:, :, i) = L_c(:, :, i) - L_s(:, :, i);
end

% Calculating the Multi-Scale Response Map
Response = 1/N * sum(sign(L) .* (abs(L)) .^ lambda, 3);
M = sign(Response) .* (abs(Response)) .^ (1/lambda);
end