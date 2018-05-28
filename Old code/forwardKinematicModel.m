function [Ach, Anh, Acn] = forwardKinematicModel(in)

global param

% Rotation in the x1 and x2 direction
psi1 = [0;0;in(1)];
theta1 = [0;in(2);0];
psi2 = [0;0;in(3)];

% C (camera point) to world coordinates (n) to H (Image point)
param.rHH11h = [param.Hx;param.Hy;0];

Rcn = eulerRotation(psi1)*eulerRotation(theta1);
% Rnh = eulerRotation(theta1);
Rnh = eulerRotation(theta1)*eulerRotation(psi2);
Rch = Rcn*Rnh;

Acn = [Rch,param.rHH11h;zeros(1,3),1];

% C (Camera Point) to H (Image point) w.r.t world coordinates
param.rH11Cn = [param.lH11Cx;param.lH11Cy;param.lH11Cz];

Anh = [Rcn,param.rH11Cn;zeros(1,3),1];

% Camera distance to checkerboard in camera coordinates
param.rHCc = Rch*param.rHH11h + Rcn*param.rH11Cn;

% Normalize?
Norm_rHCc = (param.rHCc(1).^2 + param.rHCc(2).^2 + param.rHCc(3).^2);
% Norm_rHCc = 1 - (param.rHCc(1).^2 + param.rHCc(2).^2 + param.rHCc(3).^2);
param.rHCc_norm = [param.rHCc(1)./Norm_rHCc;param.rHCc(2)./Norm_rHCc;param.rHCc(3)./Norm_rHCc];

% Homogeneous Transformation 
Ach = [Rch,param.rHCc;zeros(1,3),1];
% Ach = [Rch,param.rHCc_norm;zeros(1,3),1];