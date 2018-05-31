function [A13, A23, A12] = forwardKinematicModel(in)

global param

% Rotation in the x1 and x2 direction
psi1 = [0;0;in(1)];
psi2 = [0;0;in(2)];

% N (world point) to C (camera point)
param.rCN2 = [-param.lcx;-param.lcy;0];
R12 = eulerRotation(psi1);

A12 = [R12,param.rCN2;zeros(1,3),1];

% C (Camera Point) to H (Image point)
param.rHC3 = [param.lH11x;param.lH11y;-param.lH11z];%./sqrt(param.lH11x^2+param.lH11y^2-param.lH11z^2);
R23 = eulerRotation(psi2);

A23 = [R23,param.rHC3;zeros(1,3),1];

% Homogeneous Transformation 
A13 = A12*A23;