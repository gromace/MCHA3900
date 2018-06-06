%% Load Data
% Vector Test Data
load('Initial_image_pose.mat') %Use for POSE just for random data? 
%POSE=[N E D; theta phi psi; dtheta dphi dpsi];

load('rHCc_and_norm.mat')
load('calibration_sample_vector_points.mat')
load('px2vec_pose.mat')
N=3;

thetacb = deg2rad([90;90;90]);
thetanb = deg2rad([90;90;90]);
vCBb = [1;1;-1];
vBNb = [1;1;1];
omegaBNb = [2;2;2];
rPNn = [0.05;0.05;-0.05];
rBNn = [0.05;-0.05;-0.05];
rCbb = [0.025;0.025;0.025];
rQCc = rHCc(:,1);

%% Measurement Model
x = [thetacb;thetanb;vCBb;vBNb;omegaBNb;rPNn;rBNn;rCbb;rQCc];

for i=1:40
    yflow(:,i) = measurementModel2(x);
end

%% Plots
figure(1);clf
plot3(yflow(1,:),yflow(2,:),yflow(3,:),'x')
grid on
title('Flow Vectors')
xlabel('x') % x-axis label
ylabel('y') % y-axis label
zlabel('z')
vec=rHCc(:,2);

hold on
plot3(vec(1,1), vec(2,1),vec(3,1),'ok')



