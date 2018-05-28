function [uv_est, rHCc_norm_est, rHCc_est, Rch_est, C_est] = CamModelTuneTest(in, wPts)
global param
rcz = in(1);
rcx = in(2);
rcy = in(3);
qtransform = in(4:6);
ctpt1 = in(7);
ctpt2 = in(8);
camangles = in(9);

%% convert from mm to m
param.n = 1;

%% Parameters
param.p2m = 4.8e-6;
% qtransform = deg2rad([90;-90;90]);

% centre pf camera roguhly for image 1 in NED coords
rc_est = [0.211,rcx,rcy];

Nc_est = rc_est(1)*ones(35,1);
Ec_est = wPts(:,1,param.n) - rc_est(2).*ones(length(wPts),1);
Dc_est = -wPts(:,2,param.n) + rc_est(3).*ones(length(wPts),1);
H_est = [wPts(:,1,param.n),wPts(:,2,param.n),zeros(length(wPts),1)];

%% Sim 'Ray Cast'
for i = 1:length(wPts)
    param.Hx_est = H_est(i,1);
    param.Hy_est = H_est(i,2);
    param.lH11Cx_est = Nc_est(i);
    param.lH11Cy_est = Ec_est(i);
    param.lH11Cz_est = Dc_est(i);
    
    % Calculate Vector distances (rHNn and RHn)
    [Ach_est, Anh_est, ~] = FKMest(qtransform);
    rH11Cn_est(:,i) = Anh_est(1:3,4);
    Rnh = Anh_est(1:3,1:3);  
    
    rHCc_est(:,i) = Ach_est(1:3,4);
    Rch_est = Ach_est(1:3,1:3);
    
    rHCc_norm_est(:,i) = param.rHCc_norm_est;

end
%% Camera object: vector to pixel
C_est = CatadioptricCamera(...
    'name','Point Grey BlackFly',...
    'focal',1e-5,'centre',[ctpt1,ctpt2]',...
    'maxangle',deg2rad(camangles),'pixel',4.8e-6,...
    'resolution',[1024 1280]);%,'pose',Tpose0);

% uv_est = C_est.project([-rHCc_est(1,:);rHCc_est(2,:);rHCc_est(3,:)]);
uv_est = C_est.project([-rHCc_norm_est(1,:);rHCc_norm_est(2,:);rHCc_norm_est(3,:)]);
