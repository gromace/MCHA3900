clear all;
tic
CheckerboardDetection();
load('pixelToVector_lerp_grid.mat');
load('optimized_pixelToVector_lerp_grid.mat')
load('calibration_sample_vector_points.mat','rHCc_norm');

in = [imagePoints(:,1,1); imagePoints(:,2,1)];
% fx = Fx(in(1:35),in(36:70));
% fy = Fy(in(1:35),in(36:70));
% fz = Fz(in(1:35),in(36:70));
% in = [fx;fy;fz];
% Upper and lower bounds
lb = zeros(length(in),1);
ub = [1024*ones(length(imagePoints(:,1,1)),1); 1280*ones(length(imagePoints(:,2,1)),1)];
% ub = [1024*ones(length(in(1:35)),1);1280*ones(length(in(36:70)),1)];

options = optimoptions('fmincon','MaxFunctionEvaluations',1e6, 'PlotFcn','optimplotfval','OptimalityTolerance',1e-10,'StepTolerance',1e-10, 'Algorithm','sqp');
% options = optimoptions('fmincon','MaxFunctionEvaluations',1e6, 'PlotFcn','optimplotfval','OptimalityTolerance',1e-7,'StepTolerance',1e-10, 'Algorithm','quasi-newton');
% out = fminunc(@(in) vec2px(in, rHCc_norm, Fx, Fy, Fz), in, options);
[out, FVAL, output] = fmincon(@(in) vec2px(in, rHCc_norm, Fxstar, Fystar, Fzstar), in, [], [], [], [], lb, ub, [], options);
theta_est = vec2px(out, rHCc_norm, Fxstar, Fystar, Fzstar);

toc
%% compute the vector to pixel error
function [theta_error, p2v_p_uc_norm] = vec2px(in, uc, Fx, Fy, Fz)
    
for i=1:length(in)/2
    % px2vect/lerp LUT
    fx(i) = Fx(in(i),in(i+35));
    fy(i) = Fy(in(i),in(i+35));
    fz(i) = Fz(in(i),in(i+35));

    
    % Vectorize
    p2v_p_uc(:,i) = [fx(i);fy(i);fz(i)];
%     p2v_p_uc(:,i) = [in(i);in(i+35);in(i+70)];
    
    % Normalise since we are working in a unit sphere
    uc_norm(i) = sqrt(p2v_p_uc(1,i).^2 + p2v_p_uc(2,i).^2 + p2v_p_uc(3,i).^2);
    p2v_p_uc_norm(:,i) = [p2v_p_uc(1,i)./uc_norm(i); p2v_p_uc(2,i)./uc_norm(i); p2v_p_uc(3,i)./uc_norm(i)]; 
    
%     theta(i) = (acos(uc(:,i)' * p2v_p_uc_norm(:,i)));
    theta(i) = 1 - (uc(:,i)' * p2v_p_uc_norm(:,i));
end
 
% theta_error = -sum(theta);
% theta_error = immse(uc, p2v_p_uc_norm);
theta_error = -sum(lsqr(theta, 1));
if theta_error<0
    theta_error = abs(theta_error);
end

end