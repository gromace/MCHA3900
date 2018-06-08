%% Load Data
% Vector Test Data
clear

load('rHCc_and_norm.mat')
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

% Uncomment one model type below
%modelType = 'binary';
modelType = 'ternary';
% modelType = 'quaternary';

% Prior hypothesis probabilities (common prior for each time step)
switch modelType
    case 'ternary'          
        P_gb	= 0.4;
        P_ob	= 0.4;
        P_null	= 0.2; 
    otherwise
        error('Invalid mode');
end
assert(P_gb + P_ob  + P_null == 1, 'Prior probabilities must sum to 1');


x = [thetacb;thetanb;vCBb;vBNb;omegaBNb;rPNn;rBNn;rCbb;rQCc];

for i=1:35
    yflow(:,i) = measurementModel2(x);
end


%% Measurement Model
p.vec1 = rHCc(:,1);
p.vec2 = yflow(:,1);


% Set mu for each case
p.mu_gb = mean2(p.vec1);
p.mu_ob = mean2(p.vec2);
p.min=-1;
p.max=1;

%% Tuning parameters

% Standard deviation of measurement likelihood

sigma_gb = 0.1;  
sigma_ob = 0.1;




% Pack parameters
theta = [sigma_gb;sigma_ob;P_gb;P_ob;P_null];

%% Automatic parameter tuning
% Pack parameters (Initial guess)



% Unpack results
sigma_gb     = x(1);
sigma_ob     = x(2);
P_gb         = x(3);
P_ob         = x(4);
P_null       = x(5);


% Find optimal parameters
theta = TuningLikelihood_3(theta, modelType, p);

%% Plots
figure(2);
plot3(yflow(1,:),yflow(2,:),yflow(3,:),'x')
grid on
title('Flow Vectors')
xlabel('x') % x-axis label
ylabel('y') % y-axis label
zlabel('z')
vec=rHCc(:,2);

hold on
plot3(p.vec1(1,1), p.vec1(2,1),p.vec1(3,1),'ok')
plot3(p.vec2(1,1), p.vec2(2,1),p.vec2(3,1),'+r')
hold off



