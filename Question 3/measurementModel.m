function [yflow] = measurementModel(x,p)
% Rotation matrices 
Rcb = eulerRotation(p.thetacb);
Rnb = eulerRotation(p.thetanb);

% Vehicle Pose in camera coordinates
vCNc = Rcb*(vCBb + vBNb);
omegaBNc = Rcb*omegaBNb;

% Inverse Depth
rPC = rPNn - rBNn - Rnb*rCbb;
rhoPC = 1./sqrt(rPC(1).^2 + rPC(2).^2 + rPC(3).^2);

% measurement model
dBrPQc = S(rQCc)*[rhoPC*S(rQCc),eye(3)]*[vCNc;omegaBNc];

% measurement model with additive Gaussian noise
yflow = dBrPQc + vc;

end