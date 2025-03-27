% Generate a smooth random field and plot it as a 3D surface
% with an oblique view and a custom colormap including yellow, orange, and electric blue.

% Define grid size and create a meshgrid.
N = 30;
[X, Y] = meshgrid(linspace(-3,3,N), linspace(-3,3,N));

% Generate a random field and smooth it using a Gaussian filter.
% (Requires Image Processing Toolbox; alternatively, use conv2 with a Gaussian kernel.)
k = 3; 
Z = imgaussfilt(randn(N), k);
% Z = Z ./ std(Z(:)); % normalize
Z = Z + 1;


% mask edges for aesthetics
[Z_masked, mask] = gaussianMask(Z);

% figure; hist(Z(:))

% mask = ones(size(Z));
% mask(20:80, 20:80) = 0;
% mask = double(mask == 0);
% Z = Z .* mask;

% Create a figure and plot the surface.
create_figure('surf');
h = surf(X, Y, Z, 'EdgeColor', 'none');
shading interp;         % Smooth shading

% Set the AlphaData property to the absolute value of Z so that transparency varies with Z.
% set(h, 'AlphaData', log(1 + abs(Z))); 
% set(h, 'AlphaData', 1 - double(abs(Z) == 0)); for binary mask
set(h, 'AlphaData', mask); 

set(h, 'FaceAlpha', 'interp')

set(h, 'EdgeColor', [.5 .5 .5])

axis tight;
xlabel('X');
ylabel('Y');
zlabel('Z');
title('Smooth Random Field Surface Plot');
axis off

% Set an oblique view.
view(45, 30);

% --- Custom Colormap ---
% Define anchor colors:
% Yellow:        [1, 1, 0]
% Orange:        [1, 0.5, 0]
% Electric Blue: [0, 0.5, 1]
anchorColors = [0 0.5 1; 1 0.5 0; 1 1 0];

anchorColors = [0 1 0.5; 0 0.5 0; 1 1 0];

anchorColors = [.2 .2 1; 0 0 1; 1 0 1];

% Interpolate to create a smooth colormap with 256 colors.
nColors = 256;
customCMap = interp1(linspace(0,1,size(anchorColors,1)), anchorColors, linspace(0,1,nColors));

% Apply the custom colormap.
colormap(customCMap);
colorbar;  % Display a colorbar for reference


function [Z_masked, mask] = gaussianMask(Z)

% Assume Z is a 2D matrix representing your random field.
[rows, cols] = size(Z);

% Create a grid with (X,Y) coordinates.
[X, Y] = meshgrid(1:cols, 1:rows);

% Compute the center of the grid.
centerX = (cols + 1) / 2;
centerY = (rows + 1) / 2;

% Define the standard deviation for the Gaussian.
% Adjust sigma as needed: here, we set it to one-fourth of the smaller image dimension.
sigma = min(rows, cols) / 3;

% Create the Gaussian mask: maximum (1) at the center, decaying towards 0 at the periphery.
mask = exp(-(((X - centerX).^2 + (Y - centerY).^2) / (2 * sigma^2)));

% (Optional) Visualize the Gaussian mask.
% figure;
% imagesc(mask);
% colormap('gray');
% colorbar;
% title('Gaussian Mask');

% Apply the Gaussian mask to Z.
Z_masked = Z .* mask;

end

