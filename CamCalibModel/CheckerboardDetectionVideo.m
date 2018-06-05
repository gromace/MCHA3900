% Define images to process
V = VideoReader('Cam_Video_15frames.m4v');
V.CurrentTime = 251/V.FrameRate;

% Sample 31 frames: this number can be varied depending on how much time
% you want to spend calibrating
x = 1:50:1726;

i = 1; j = 1;
while hasFrame(V)
    vid = readFrame(V);
    if i == x(j)
       imageFileNames(:,:,:,j) = vid;
       j = j + 1;
    end
    i = i + 1;
end

% Detect checkerboards in images
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imageFileNames);
imageFileNamesUsed = imageFileNames(imagesUsed);

% Generate world coordinates of the corners of the squares
squareSize = 0.0285;  % in units of 'metres'
worldPoints = generateCheckerboardPoints(boardSize, squareSize);