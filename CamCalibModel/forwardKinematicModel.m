function [Ach, Anh, Acn, Ach_norm] = forwardKinematicModel(in)

% Rotation in the x1 and x2 direction
psi1 = [0;0;in(1)];
theta1 = [0;in(2);0];
psi2 = [0;0;in(3)];

% Pixel Distances
Hx = in(4);
Hy = in(5);
lH11Cx = in(6);
lH11Cy = in(7);
lH11Cz = in(8);
    
% C (camera point) to world coordinates (n) to H (Image point)
rHH11h = [Hx;Hy;0];

Rcn = eulerRotation(psi1)*eulerRotation(theta1);
Rnh = eulerRotation(theta1)*eulerRotation(psi2);
Rch = Rcn*Rnh;

Acn = [Rch,rHH11h;zeros(1,3),1];

% C (Camera Point) to H (Image point) w.r.t world coordinates
rH11Cn = [lH11Cx;lH11Cy;lH11Cz];

Anh = [Rcn,rH11Cn;zeros(1,3),1];

% Camera distance to checkerboard in camera coordinates
rHCc = Rch*rHH11h + Rcn*rH11Cn;

% Normalize?
Norm_rHCc = sqrt(rHCc(1).^2 + rHCc(2).^2 + rHCc(3).^2);
% Norm_rHCc = 1 - (param.rHCc(1).^2 + param.rHCc(2).^2 + param.rHCc(3).^2);

rHCc_norm = [rHCc(1)./Norm_rHCc;rHCc(2)./Norm_rHCc;rHCc(3)./Norm_rHCc];

% Homogeneous Transformation 
Ach = [Rch,rHCc;zeros(1,3),1];

Ach_norm = [Rch,rHCc_norm;zeros(1,3),1];