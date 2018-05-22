rc = [0.211;0.0875;0.1115];
qtransform = deg2rad([90;-90;90]);
rCHc = rc;
Rch = [-1,0,-0;0,1,-0;0,0,-1];

% CheckerboardDetection();

lb = [0.1, 0.01, 0.01, deg2rad(90),deg2rad(-90),deg2rad(90)];
ub = [0.312, 0.1, 0.45, deg2rad(90),deg2rad(-90),deg2rad(90)];

in = [rc; qtransform; rCHc];

options = optimoptions(@fmincon,'MaxFunctionEvaluations',3700, 'PlotFcn', 'optimplotfval');
o = fmincon(@(in) px2vec(in, imagePoints, worldPoints), in,[],[],[],[],lb,ub,options);

rc_tuned = o(1:3)
q_tuned = rad2deg(o(4:6))
q1 = o(4); q2 = o(5); q3 = o(6);

Rch_tuned = [...
       cos(q1)*cos(q2)^2*cos(q3) - sin(q1)*sin(q3) - cos(q1)*cos(q3)*sin(q2)^2, cos(q1)*sin(q2)^2*sin(q3) - cos(q1)*cos(q2)^2*sin(q3) - cos(q3)*sin(q1), 2*cos(q1)*cos(q2)*sin(q2);
       cos(q1)*sin(q3) + cos(q2)^2*cos(q3)*sin(q1) - cos(q3)*sin(q1)*sin(q2)^2, cos(q1)*cos(q3) - cos(q2)^2*sin(q1)*sin(q3) + sin(q1)*sin(q2)^2*sin(q3), 2*cos(q2)*sin(q1)*sin(q2);
                                                   -2*cos(q2)*cos(q3)*sin(q2),                                               2*cos(q2)*sin(q2)*sin(q3),     cos(q2)^2 - sin(q2)^2]
% options = optimoptions(@fminunc,'MaxFunctionEvaluations',3700, 'PlotFcn', 'optimplotfval');
% out = fminunc(@(in) px2vec(in, imagePoints, worldPoints), in, options)
