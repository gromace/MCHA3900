function [Ach, Anh, Acn] = FKMest(in)

global param

% Rotation in the x1 and x2 direction
psi1 = [0;0;in(1)];
theta1 = [0;in(2);0];
psi2 = [0;0;in(3)];

% C (camera point) to world coordinates (n) to H (Image point)
param.rHH11h_est = [param.Hx_est;param.Hy_est;0];

Rcn = eulerRotation(psi1)*eulerRotation(theta1);
% Rnh = eulerRotation(theta1);
Rnh = eulerRotation(theta1)*eulerRotation(psi2);
Rch = Rcn*Rnh;

Acn = [Rch,param.rHH11h_est;zeros(1,3),1];

% C (Camera Point) to H (Image point) w.r.t world coordinates
param.rH11Cn_est = [param.lH11Cx_est;param.lH11Cy_est;param.lH11Cz_est];

Anh = [Rcn,param.rH11Cn_est;zeros(1,3),1];

% Camera distance to checkerboard in camera coordinates
param.rHCc_est = Rch*param.rHH11h_est + Rcn*param.rH11Cn_est;

% Normalize?
Norm_rHCc = (param.rHCc_est(1).^2 + param.rHCc_est(2).^2 + param.rHCc_est(3).^2);
param.rHCc_norm_est = [param.rHCc_est(1)./Norm_rHCc;param.rHCc_est(2)./Norm_rHCc;param.rHCc_est(3)./Norm_rHCc];

% Homogeneous Transformation 
Ach = [Rch,param.rHCc_est;zeros(1,3),1];
% Ach = [Rch,param.rHCc_norm;zeros(1,3),1];