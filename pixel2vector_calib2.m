%% Initialisation
clear all;clc
global param
tic
%% Waitbar
delete(findall(0,'tag','TMWWaitbar'));

param.wh = waitbar(0,getMsg, ...
    'Name', 'MCHA3900 Project', ...
    'CreateCancelBtn', 'setappdata(gcbf,''cancelling'',1)');
%% Calibration
% Find checkerboard corners
% CheckerboardDetection();
CheckerboardDetectionVideo();
waitbar(0.25,param.wh); % Update waitbar
im_num = 2;

fs = 20;
% worldPoints(:,:) = worldPoints(:,:)*1e-3;
% Number of frames
param.k = length(imageFileNamesUsed);

% Initial image pose and pixel to vector grid
load('Initial_image_pose.mat')
load('pixelToVector_lerp_grid.mat');
load('calibration_sample_vector_points.mat')

Ach_est(:,:,1) = Ach_init_est;

% Set the initial pose
init_pose = [Ach_est(1:3,1);Ach_est(1:3,2);Ach_est(1:3,3);Ach_est(1:3,4)];
intc = repmat(init_pose,param.k,1);
waitbar(0.3,param.wh); % Update waitbar

%% Run optimization for pixel to vector function
A = [repmat([ones(1,9),inf*ones(1,3)],1,param.k);
    -repmat([ones(1,9),inf*ones(1,3)],1,param.k)];
B = deg2rad([190;-190]);
options = optimoptions(@fmincon,'MaxFunctionEvaluations',1e6,'Algorithm','sqp', 'PlotFcn',...
                       'optimplotfval','OptimalityTolerance',1e-10,'MaxIterations',200); 
out = fmincon(@(intc) px2vec2(intc, worldPoints, imagePoints, param.k, Fx, Fy, Fz), intc,...
                               [], [], [], [], [], [], @norm_vect, options);
waitbar(0.75,param.wh); % Update waitbar

% Compute the optimised vectors and pose
[~, ustar, ucn, Ach] = px2vec2(out, worldPoints, imagePoints, param.k, Fx, Fy, Fz);
ustar = ustar./param.k;
disp(['simulation run time: ',num2str(toc/60),' mins'])

%% How's the waitbar going bois?
try 
catch hot_potato
    delete(param.wh); % Remove waitbar if error
    rethrow(hot_potato); % Someone else's problem now
end
waitbar(1,param.wh); % Update waitbar
close
delete(param.wh); % Remove waitbar if we complete successfully

%% Plots
figure(44);clf
for i=im_num
    plot3(0,0,0,'o',-ucn(:,1,i),ucn(:,2,i),ucn(:,3,i),'x-')
    % view(0,90)
    for j=1:length(worldPoints)
        strnum(j) = {['',num2str(j)]};
    end;clear j
    text(-ucn(:,1,i),ucn(:,2,i),ucn(:,3,i),strnum)
    text(0,0,0,'CamOrigin')
    hold on
end
title(['Frame ',num2str(im_num)],'FontSize',fs)
% legend('pixeltovec (u^{c}_{ij})','measured r_{H_{ij}/C}^{c}')
xlabel('c1 (unit)','FontSize',fs)
ylabel('c2 (unit)','FontSize',fs)
zlabel('c3 (unit)','FontSize',fs)
grid on

figure(45);clf
plot3(-ustar(:,1),ustar(:,2),ustar(:,3),'x-',0,0,0,'o')
% view(0,90)
title('u*_{ij}','FontSize',fs)
for j=1:length(worldPoints)
    strnum(j) = {['',num2str(j)]};
end;clear j
text(-ustar(:,1),ustar(:,2),ustar(:,3),strnum)
text(0,0,0,'CamOrigin')
% legend('pixeltovec (u^{c}_{ij})','measured r_{H_{ij}/C}^{c}')
xlabel('c1 (unit)','FontSize',fs)
ylabel('c2 (unit)','FontSize',fs)
zlabel('c3 (unit)','FontSize',fs)
grid on

% figure('Name',['Calibration Image ',num2str(im_num)],'NumberTitle','off');clf
figure(46);clf
imshow(imageFileNames(:,:,:,im_num))

%% Nonlincon
function [c,ceq] = norm_vect(intc)
global param

c=[];

for l=1:param.k
    ceq(12*l-2 : 12*l) = 1 - sqrt(intc(12*l-2).^2 + intc(12*l-1).^2 + intc(12*l).^2);
end
end