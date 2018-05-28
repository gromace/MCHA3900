%% Parameters
n = 1;            % Image
IMAG_UP = 20;      % Enhance Image
IMAGE_DOWN = 20;   % Pixelate Image

% Load Images unto a grid
CheckerboardDetection()
sample_image = imread(imageFileNames{n});

%% Create Interpolant
F = griddedInterpolant(double(sample_image),'linear','nearest');

%% Resample Image Pixels: 
[sx,sy,sz] = size(sample_image);

% High Resolution
xq1 = (0:1/IMAG_UP:sx)';
yq1 = (0:1/IMAG_UP:sy)';
zq1 = (1:sz)';
sample_image_highres = uint8(F({xq1,yq1,zq1}));


% Low Resolution
xq2 = (0:IMAGE_DOWN:sx)';
yq2 = (0:IMAGE_DOWN:sy)';
zq2 = (1:sz)';
sample_image_lowres = uint8(F({xq2,yq2,zq2}));

%% show orignal and tampered images
figure(121)
imshow(sample_image,'InitialMagnification','fit')
title('Raw Image','FontSize',20)

figure(123)
imshow(sample_image_highres,'InitialMagnification','fit')
title('Higher Resolution','FontSize',20)

figure(124)
imshow(sample_image_lowres,'InitialMagnification','fit')
title('Lower Resolution','FontSize',20)
