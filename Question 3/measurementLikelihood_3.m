% Main Script for determining measurement likelihood 
%
%
%
clear all
%% Load Data
% Vector Test Data
load('Initial_image_pose.mat') %Use for POSE just for random data? 
%POSE=[N E D; theta phi psi; dtheta dphi dpsi];

load('calibration_sample_vector_points.mat')
N=100;
p.vc = 0.5*randn(N,1)+1;
p.vec1 = rHCc_norm(:,1);
p.vec2 = rHCc_norm(:,2);


% Set mu for each case
p.mu_cex_is = mean2(p.vec1);
p.mu_cex_pl = mean2(p.vec2);
p.min=-1;
p.max=1;

%% Tuning parameters

% Standard deviation of measurement likelihood

sigma_cex_is = 0.5;  
sigma_cex_pl = 0.5;


% Uncomment one model type below
%modelType = 'binary';
modelType = 'ternary';
% modelType = 'quaternary';

% Prior hypothesis probabilities (common prior for each time step)
switch modelType
    case 'ternary'          
        P_is	= 0.5;
        P_pl	= 0;
        P_null	= 0.5; 
    otherwise
        error('Invalid mode');
end
assert(P_is + P_pl  + P_null == 1, 'Prior probabilities must sum to 1');

% Pack parameters
theta = [sigma_cex_is;sigma_cex_pl;P_is;P_pl;P_null];

%% Automatic parameter tuning
p.thetacb= 0.2;
p.thetanb= 0.2;
p.vCBb= 0;
p.vBNb= 0;
p.omegaBNb= 0 ;
p.RPNn= [1 0 0;0 1 0;0 0 1];
p.RBNn= [1 0 0;0 1 0;0 0 1];
p.rCbb= [1;1;1];
p.rQCc= rHCc_norm;


% Find optimal parameters
theta = TuningLikelihood_3(theta, modelType, p);