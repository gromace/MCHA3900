%% Spherical Camera Calibration Model
% clear all
%close all

% Font Size
fs = 15;

%% Image processing
% TODO: load and detect checkerboard points
n = 1;
CheckerboardDetection();

% convert from mm to m
worldPoints(:,:,n) = worldPoints(:,:,n)*1e-3;

%% Parameters
global param

param.p2m = 4.8e-6;

qtransform = deg2rad([90;-90;90]);

% centre roguhly for image 1 in NED coords
rc = [0.211;0.0875;0.1115];
% rc = [0.211;0.0025;0.1115];

% Tuned suckers
AutotuneParameters1
rc =rc_tuned;
qtransform = deg2rad(q_tuned);

waitbar(toc,wh); % Update waitbar

Nc = rc(1)*ones(35,1);
Ec = worldPoints(:,1,n) - rc(2).*ones(length(worldPoints),1);
Dc = -worldPoints(:,2,n) + rc(3).*ones(length(worldPoints),1);
H = [worldPoints(:,1,n),worldPoints(:,2,n),zeros(length(worldPoints),1)];

%% Sim 'Ray Cast'
for i = 1:length(worldPoints)
    param.Hx = H(i,1);
    param.Hy = H(i,2);
    param.lH11Cx = Nc(i);
    param.lH11Cy = Ec(i);
    param.lH11Cz = Dc(i);
    
    % Calculate Vector distances (rHNn and RHn)
    [Ach, Anh, ~] = forwardKinematicModel(qtransform);
    rH11Cn(:,i) = Anh(1:3,4);
    Rnh = Anh(1:3,1:3);  
    
    rHCc(:,i) = Ach(1:3,4);
    Rch = Ach(1:3,1:3);
    
    rHCc_norm(:,i) = param.rHCc_norm;
%     rHCc(1,i) = -rHCc(1,i);
    pose = Rch*rHCc;
   
end
Ach11 = [Rch,rHCc(:,1);zeros(1,3),1];

Norm_rPCc = sqrt(imagePoints(:,1,n).^2 + imagePoints(:,2,n).^2);
rPCc = [imagePoints(:,1,n)./Norm_rPCc(:),imagePoints(:,2,n)./Norm_rPCc(:)];
%% Estimation
% rHCc = (rHCc./2) - rHCc(:,1)./2;
p2m = param.p2m .* imagePoints;
p2mr=[p2m(:,1)';p2m(:,2)';zeros(1,35)];

ru = rHCc(1,:)./rHCc(3,:);
rv = rHCc(2,:)./rHCc(3,:);

est = (rHCc - p2mr).^2;

xerr = lsqr(rHCc(1,:)',p2mr(1,:)');
yerr = lsqr(rHCc(2,:)',p2mr(2,:)');

% CamProjection1;

%% Auto tune parameters: fminunc
% ctpt = [524,544];
% camangle = 190;
% 
% % Stack tuning parameters
% in = [rc',qtransform', ctpt, camangle];
% 
% % Auto tune parameters
% [uv_tuned, rHCc_norm_tuned, rHCc_tuned, Rch_tuned, C_tuned] = AutotuneParameters(in, worldPoints, imagePoints);
%% Plots 
% TODO: plots for Pose
figure(1);clf
% plot3(rHCc(1,:),rHCc(2,:),rHCc(3,:),'r+',0,0,0,'r+',rHCc_tuned(1,:),rHCc_tuned(2,:),rHCc_tuned(3,:),'b+')
plot3(rHCc(1,:),rHCc(2,:),rHCc(3,:),'r+',0,0,0,'r+')
text(0,0,0,'CameraOrigin')
view(-145,-45)
for j=1:length(worldPoints)
    strnum(j) = {['',num2str(j)]};
end;clear j
text(rHCc(1,:),rHCc(2,:),rHCc(3,:),strnum);
% text(rHCc_tuned(1,:),rHCc_tuned(2,:),rHCc_tuned(3,:),strnum);clear strnum
title('distance from cam to corner from cam perspective r_{H_{ij}/C}^{c}','FontSize',fs)
xlabel('c1 (m)','FontSize',fs)
ylabel('c2 (m)','FontSize',fs)
zlabel('c3 (m)','FontSize',fs)
grid on

figure(2);clf
plot3(rH11Cn(1,:),rH11Cn(2,:),rH11Cn(3,:),'r+',0,0,0,'ro')
text(0,0,0,'CameraOrigin')
% view(-145,45)
view(-145,45+90)
for j=1:length(worldPoints)
    strnum(j) = {['',num2str(j)]};
end;clear j
text(rH11Cn(1,:),rH11Cn(2,:),rH11Cn(3,:),strnum);clear strnum
title('distance from cam to corner from world coordinates r_{H_{ij}/C}^{n}','FontSize',fs)
xlabel('North (m)','FontSize',fs)
ylabel('East (m)','FontSize',fs)
zlabel('Down (m)','FontSize',fs)
grid on

figure(3);clf
plot(worldPoints(:,1,n),worldPoints(:,2,n),'x')
for j=1:length(worldPoints)
    strnum(j) = {['',num2str(j)]};
end;clear j
text(worldPoints(:,1,n),worldPoints(:,2,n),strnum);clear strnum
title('Real World Points of checkerboard r_{H_{ij}/H_{11}}^{h}','FontSize',fs)
xlabel('h1 (m)','FontSize',fs)
ylabel('h2 (m)','FontSize',fs)
grid on
xlim([-0.01 0.18])
ylim([-0.01 0.12])

% figure(4);clf
% imshow(imageFileNames{n})
% hold on
% plot(imagePoints(:,1,n),imagePoints(:,2,n),'rx')
% for j=1:length(worldPoints)
%     strnum(j) = {['',num2str(j)]};
% end;clear j
% text(imagePoints(:,1,n),imagePoints(:,2,n),strnum);clear strnum
% hold on
% plot(640,512,'ro')
% grid on

figure(5);clf
plot(imagePoints(:,1,n),imagePoints(:,2,n),'rx')
for j=1:length(worldPoints)
    strnum(j) = {['',num2str(j)]};
end;clear j
text(imagePoints(:,1,n),imagePoints(:,2,n),strnum);clear strnum
hold on
plot(640,512,'ro')
grid on
title('Image corners coordinates','FontSize',fs)
ylabel('v distance of corners (px)','FontSize',fs)
xlabel('u distance of corners (px)','FontSize',fs)
% xlim([0 1024])
% ylim([0 1280])

figure(6);clf
plot(p2m(:,1,n),p2m(:,2,n),'rx')
for j=1:length(worldPoints)
    strnum(j) = {['',num2str(j)]};
end;clear j
text(p2m(:,1,n),p2m(:,2,n),strnum);clear strnum
title('Image corners coordinates in millimeters, 4.8\mum pizel size','FontSize',fs)
ylabel('v distance of corners (m)','FontSize',fs)
xlabel('u distance of corners (m)','FontSize',fs)
grid on

figure(7);clf
im_z = 1 - imagePoints(:,1,n).^2 - imagePoints(:,2,n).^2;
plot3(imagePoints(:,1,n),imagePoints(:,2,n),im_z,'x')
view(0,90)
for j=1:length(worldPoints)
    strnum(j) = {['',num2str(j)]};
end;clear j
text(imagePoints(:,1,n),imagePoints(:,2,n),im_z(:),strnum);clear strnum
title('Image corners coordinates with estimated Z coord','FontSize',fs)
xlabel('u (px)','FontSize',fs)
ylabel('v (px)','FontSize',fs)
zlabel('w (px)','FontSize',fs)
grid on

% figure(8);clf
% plot(uv(1,:),uv(2,:),'kx-',uv_tuned(1,:),uv_tuned(2,:),'bx-',imagePoints(:,1),imagePoints(:,2),'rx-')
% text(imagePoints(1,1),imagePoints(1,2),'1')
% text(uv_tuned(1,1),uv_tuned(2,1),'1')
% title('fmin*** tuning','FontSize',fs)
% xlabel('u (px)','FontSize',fs)
% ylabel('v (px)','FontSize',fs)
% legend('Default Estimated r_{H/C}^{c}','fminunc Estimated r_{H/C}^{c}','Actual r_{H/C}^{c}')
% grid on