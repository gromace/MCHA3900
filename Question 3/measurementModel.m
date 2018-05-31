function [yflow] = measurementModel(x,p)
% Rotation matrices 
Rcb = eulerRotation(p.thetacb);
Rnb = eulerRotation(p.thetanb);

% Vehicle Pose in camera coordinates
vCNc = Rcb*(p.vCBb + p.vBNb);
omegaBNc = Rcb*p.omegaBNb;

% Inverse Depth
rPC = p.rPNn - p.rBNn - Rnb*p.rCbb;
rhoPC = 1./sqrt(rPC(1).^2 + rPC(2).^2 + rPC(3).^2);

% measurement model
dBrPQc = S(p.rQCc)*[rhoPC*S(p.rQCc),eye(3)]*[vCNc;omegaBNc];

% measurement model with additive Gaussian noise
yflow = dBrPQc + p.vc;

end