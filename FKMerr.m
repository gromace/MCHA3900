function [Ach, Anh, Acn] = FKMerr(in)

global param

% Rotation in the x1 and x2 direction
psi1 = [0;0;in(1)];
theta1 = [0;in(2);0];
psi2 = [0;0;in(3)];

% C (camera point) to world coordinates (n) to H (Image point)
param.rHH11h_err = [param.Hx_err;param.Hy_err;0];

Rcn = eulerRotation(psi1)*eulerRotation(theta1);
% Rnh = eulerRotation(theta1);
Rnh = eulerRotation(theta1)*eulerRotation(psi2);
Rch = Rcn*Rnh;

Acn = [Rch,param.rHH11h_err;zeros(1,3),1];

% C (Camera Point) to H (Image point) w.r.t world coordinates
param.rH11Cn_err = [param.lH11Cx_err;param.lH11Cy_err;param.lH11Cz_err];

Anh = [Rcn,param.rH11Cn_err;zeros(1,3),1];

% Camera distance to checkerboard in camera coordinates
param.rHCc_err = Rch*param.rHH11h_err + Rcn*param.rH11Cn_err;

% Normalize?
Norm_rHCc = (param.rHCc_err(1).^2 + param.rHCc_err(2).^2 + param.rHCc_err(3).^2);
param.rHCc_norm_err = [param.rHCc_err(1)./Norm_rHCc;param.rHCc_err(2)./Norm_rHCc;param.rHCc_err(3)./Norm_rHCc];

% Homogeneous Transformation 
Ach = [Rch,param.rHCc_err;zeros(1,3),1];
% Ach = [Rch,param.rHCc_norm;zeros(1,3),1];