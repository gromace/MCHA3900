function [uv_tuned, rHCc_norm_tuned, rHCc_tuned, Rch_tuned, C_tuned] = AutotuneParameters(in, worldPoints, imagePoints)

% options = optimoptions(@fminunc,'MaxFunctionEvaluations',1700, 'PlotFcn', 'optimplotfval');
% out = fminunc(@(in) camModelErrorTest(in, worldPoints, imagePoints), in, options)
% 
% out1 = [0.2110,0.0245,0.1105 deg2rad(143.9233),deg2rad(-91.0200),deg2rad(196.7384),632.3261,562.5677,-17.5710]   
% 
% % Run the model with the tuned parameters 
% [uv_tuned, rHCc_norm_tuned, rHCc_tuned, Rch_tuned, C_tuned] = CamModelTuneTest(out1, worldPoints);

%% fmincon: the optimizer you should be using
% lb = [0.2110,0.0245,0.1105 deg2rad(143.9233),deg2rad(-91.0200),deg2rad(196.7384),632.3261,562.5677,-17.5710] - 0.1;
% ub = [0.2110,0.0245,0.1105 deg2rad(143.9233),deg2rad(-91.0200),deg2rad(196.7384),632.3261,562.5677,-17.5710] + 0.1;
lb = [0.211, 0.02, 0.1, deg2rad(140),deg2rad(-93),deg2rad(195), 631, 561, -20];
ub = [0.211, 0.03, 0.15, deg2rad(145),deg2rad(-92),deg2rad(197), 635, 565, -15];

Aeq = zeros(1,9);
Beq = 0;

options = optimoptions(@fmincon,'MaxFunctionEvaluations',3700, 'PlotFcn', 'optimplotfval');
[out1,FVAL,EXITFLAG,OUTPUT,LAMBDA,GRAD] = fmincon(@(in) camModelErrorTest(in, worldPoints, imagePoints), in, [], [], Aeq, Beq, lb, ub,[],options)

% Run the model with the tuned parameters 
[uv_tuned, rHCc_norm_tuned, rHCc_tuned, Rch_tuned, C_tuned] = CamModelTuneTest(out1, worldPoints);