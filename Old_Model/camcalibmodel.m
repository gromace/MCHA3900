%% Spherical Camera Calibration Model
clear all
close all

%% Image processing
% TODO: load and detect checkerboard points
n = 1;
CheckerboardDetection();
xc = imagePoints(:,1,n);
yc = imagePoints(:,2,n);
zc = real(cos(asin(xc./(cos(atan(yc./xc))))));
%% Parameters
global param

param.p2m = 4.8e-6;

for i = 1:length(worldPoints)
    param.lcx = 0.0387;
    param.lcy = 0.0211;
    param.lH11x = xc(i);
    param.lH11y = yc(i);
    param.lH11z = zc(i);

    qtransform = deg2rad([180;90]);
    
    %% Calculate pose (rHNn and RHn)
    [A13, A12, A23] = forwardKinematicModel(qtransform);
    rHNn(:,i) = A13(1:3,4);
    RHn = A13(1:3,1:3);
end
%% Plots
% TODO: plots for Pose
figure(1);clf
plot(rHNn(1,:),rHNn(2,:),'r+')
for j=1:length(worldPoints)
    str(j) = {['',num2str(j)]};
end
text(rHNn(1,:),rHNn(2,:),str);clear str
title('Effector Pose, r_{N/H}^{n}')
grid on

figure(2);clf
imshow(imageFileNames{1,n})
hold on
plot(imagePoints(:,1,n),imagePoints(:,2,n),'rx')
for i=1:length(worldPoints)
    str(i) = {['',num2str(i)]};
end
text(imagePoints(:,1,n),imagePoints(:,2,n),str)
grid on
xlim([0 1280])
ylim([0 1024])

figure(3);clf
plot(imagePoints(:,1,n),imagePoints(:,2,n),'rx')
text(imagePoints(:,1,n),imagePoints(:,2,n),str)
grid on
title('Image corners coordinates')

xlim([0 1280])
ylim([0 1024])

figure(3);clf
p2m = param.p2m * imagePoints;
plot(p2m(:,1,n),p2m(:,2,n),'rx')
text(p2m(:,1,n),p2m(:,2,n),str)
title('Image corners coordinates in millimeters, 4.8\mum')
ylabel('distance of corners (mm)')
xlabel('distance of corners (mm)')
grid on