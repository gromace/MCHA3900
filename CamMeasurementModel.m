function [rHCc, rHCc_norm, Rch] = CamMeasurementModel(rc, qtransform, worldPoints)
%% Spherical Camera Calibration Model
n = 1;

% convert from mm to m
worldPoints(:,:,n) = worldPoints(:,:,n)*1e-3;

%% Parameters
global param

param.p2m = 4.8e-6;

% qtransform = deg2rad([90;-90;90]);

% centre roguhly for image 1 in NED coords
% rc = [0.211;0.0875;0.1115];
% rc = [0.211;0.0025;0.1115];

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
