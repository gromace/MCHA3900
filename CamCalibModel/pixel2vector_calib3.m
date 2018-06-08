%% Initialisation
clear all;clc
global param
tic
% fontsize for plots
fs = 20;
%% Waitbar
delete(findall(0,'tag','TMWWaitbar'));

param.wh = waitbar(0,getMsg, ...
    'Name', 'MCHA3900 Project', ...
    'CreateCancelBtn', 'setappdata(gcbf,''cancelling'',1)');
%% Grid Sample Generation
ImageGridCol = 7;       % x-direction propagation
ImageGridRow = 5;       % y-direction propagation

start = 400;
finish = 860;

xstep = (finish - start)/ImageGridRow;
ystep = (finish - start)/ImageGridCol;

u = start:xstep:finish-1;
v = start:ystep:finish-1;

%% Calibration
% Find checkerboard corners: Select between images and video
% CheckerboardDetection();
CheckerboardDetectionVideo();

waitbar(0.25,param.wh); % Update waitbar
im_num = 1;             % Select frame to plot

% Number of frames
param.k = length(imageFileNamesUsed);

% Initial image pose and pixel to vector grid
load('Initial_image_pose.mat')
load('pixelToVector_lerp_grid.mat');
load('pixelToVector_nlerp_grid.mat');
load('calibration_sample_vector_points.mat')

Ach_est(:,:,1) = Ach_init_est;

% Set the initial pose: input angles and vector
init_pose = [deg2rad([90;-90;90]);Ach_est(1:3,4)];
intc2 = [repmat(init_pose,param.k,1);rHCc(1,:)';rHCc(2,:)';rHCc(3,:)'];
waitbar(0.3,param.wh); % Update waitbar

%% Run optimization for pixel to vector function
lb = -[repmat([deg2rad(95)*ones(1,3),inf*ones(1,2),0],1,param.k),inf*ones(1,105)];
ub = [repmat([deg2rad(95)*ones(1,3),inf*ones(1,3)],1,param.k),inf*ones(1,105)];

options = optimoptions(@fmincon,'MaxFunctionEvaluations',1e6,'Algorithm','sqp', 'PlotFcn',...
                       'optimplotfval','OptimalityTolerance',1e-10,'MaxIterations',500); 

[out, fval, foutput] = fmincon(@(intc2) px2vec3(intc2, worldPoints, imagePoints, param.k, u, v), intc2,...
                               [], [], [], [], lb, ub, @norm_vect, options);

[~, ustar, ~, ~] = px2vec3(out, worldPoints, imagePoints, param.k, u, v);
%% Transformation angle per frame processed
psi1 = rad2deg(out(1:6:6*param.k));
theta1 = rad2deg(out(2:6:6*param.k));
phi1 = rad2deg(out(3:6:6*param.k));

waitbar(0.75,param.wh); % Update waitbar

%% Update grid with optimised Uij* values
[Fxstar, Fystar, Fzstar] = updateGrid(ustar');
% save('optimized_pixelToVector_nlerp_grid.mat','Fxstar', 'Fystar', 'Fzstar');
for i=1:param.k
    ucn(:,:,i) = [Fxstar(imagePoints(:,1,i),imagePoints(:,2,i)),Fystar(imagePoints(:,1,i),imagePoints(:,2,i)),Fzstar(imagePoints(:,1,i),imagePoints(:,2,i))];
end
% Compute the optimised vectors and pose
[~, ustar, ~, Ach] = px2vec3(out, worldPoints, imagePoints, param.k, u, v);
waitbar(0.85,param.wh); % Update waitbar
ustar = ustar./param.k;

disp(['simulation run time: ',num2str(toc/60),' mins','( ',num2str(toc),' seconds)'])

%% How's the waitbar going bois?
try 
catch hot_potato
    delete(param.wh); % Remove waitbar if error
    rethrow(hot_potato); % Someone else's problem now
end
waitbar(1,param.wh); % Update waitbar
delete(param.wh); % Remove waitbar if we complete successfully

%% Plots
figure(44);clf
for i=im_num
    plot3(0,0,0,'o',ucn(:,1,i),ucn(:,2,i),ucn(:,3,i),'x-')
    for j=1:length(worldPoints)
        strnum(j) = {['',num2str(j)]};
    end;clear j
    text(ucn(:,1,i),ucn(:,2,i),ucn(:,3,i),strnum)
    text(0,0,0,'CamOrigin')
    hold on
end
title(['Frame ',num2str(im_num)],'FontSize',fs)
xlabel('c1 (unit)','FontSize',fs)
ylabel('c2 (unit)','FontSize',fs)
zlabel('c3 (unit)','FontSize',fs)
grid on

figure(46);clf
imshow(imageFileNames(:,:,:,im_num))