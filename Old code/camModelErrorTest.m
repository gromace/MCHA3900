function [total_error] = camModelErrorTest(in, WPts, imPts)
global param
%% Gather and sort parameters
rcz = in(1);
rcx = in(2);
rcy = in(3);
qtransform = in(4:6);
ctpt1 = in(7);
ctpt2 = in(8);
camangles = in(9);


%% Image Number
param.n = 1;

%% Parameters

param.p2m = 4.8e-6;
% qtransform = deg2rad([90;-90;90]);

% centre pf camera roguhly for image 1 in NED coords
rc_err = [0.211,rcx,rcy];

Nc_err = rc_err(1)*ones(35,1);
Ec_err = WPts(:,1,param.n) - rc_err(2).*ones(length(WPts),1);
Dc_err = -WPts(:,2,param.n) + rc_err(3).*ones(length(WPts),1);
H_err = [WPts(:,1,param.n),WPts(:,2,param.n),zeros(length(WPts),1)];

%% Sim 'Ray Cast'
for i = 1:length(WPts)
    param.Hx_err = H_err(i,1);
    param.Hy_err = H_err(i,2);
    param.lH11Cx_err = Nc_err(i);
    param.lH11Cy_err = Ec_err(i);
    param.lH11Cz_err = Dc_err(i);
    
    % Calculate Vector distances (rHNn and RHn)
    [Ach_err, Anh_err, ~] = FKMerr(qtransform);
    rH11Cn_err(:,i) = Anh_err(1:3,4);
    Rnh_err = Anh_err(1:3,1:3);  
    
    rHCc_err(:,i) = Ach_err(1:3,4);
    Rch_err = Ach_err(1:3,1:3);
    
    rHCc_norm_err(:,i) = param.rHCc_norm_err;
    pose_err = Rch_err*rHCc_err;
end
%% Camera object: vector to pixel
C_err = CatadioptricCamera(...
    'name','Point Grey BlackFly',...
    'focal',1e-5,'centre',[ctpt1,ctpt2],...
    'maxangle',deg2rad(camangles),'pixel',4.8e-6,...
    'resolution',[1024 1280]);%,'pose',Tpose0);

% uv_err = C.project([-rHCc(1,:);rHCc(2,:);rHCc(3,:)]);
uv_err = C_err.project([-rHCc_norm_err(1,:);rHCc_norm_err(2,:);rHCc_norm_err(3,:)]);

%% Error output
total_error = immse(uv_err',imPts);