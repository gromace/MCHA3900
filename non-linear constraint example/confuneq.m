function [c, ceq] = confuneq(in)
% Nonlinear equality constraints
c = [];
ceq = sqrt(in(1)^2 + in(2)^2 + in(3)^2) - 1;
end
