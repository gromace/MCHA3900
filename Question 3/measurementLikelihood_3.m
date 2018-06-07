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

p.vec1 = rHCc_norm(:,1);
p.vec2 = rHCc_norm(:,2);


% Set mu for each case
p.mu_gb = mean2(p.vec1);
p.mu_ob = mean2(p.vec2);
p.min=-1;
p.max=1;

%% Tuning parameters

% Standard deviation of measurement likelihood

sigma_gb = 0.5;  
sigma_ob = 0.5;


% Uncomment one model type below
%modelType = 'binary';
modelType = 'ternary';
% modelType = 'quaternary';

% Prior hypothesis probabilities (common prior for each time step)
switch modelType
    case 'ternary'          
        P_gb	= 0.5;
        P_ob	= 0;
        P_null	= 0.5; 
    otherwise
        error('Invalid mode');
end
assert(P_gb + P_ob  + P_null == 1, 'Prior probabilities must sum to 1');

% Pack parameters
theta = [sigma_gb;sigma_ob;P_gb;P_ob;P_null];

%% Automatic parameter tuning
% Pack parameters (Initial guess)


% Find optimal parameters
theta = TuningLikelihood_3(theta, modelType, p);