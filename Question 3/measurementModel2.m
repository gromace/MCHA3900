function [yflow] = measurementModel2(x)
% Unpack parameters
thetacb = x(1:3);
thetanb = x(4:6);
vCBb = x(7:9);
vBNb = x(10:12);
omegaBNb = x(13:15);
rPNn = x(16:18);
rBNn = x(19:21);
rCbb = x(22:24);
rQCc = x(25:27);
vc = [x(27:30),x(31:33),x(34:36)];

% Rotation matrices 
Rcb = eulerRotation(thetacb);
Rnb = eulerRotation(thetanb);

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