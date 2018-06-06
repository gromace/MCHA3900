%% Nonlincon: Constrain the 3 coordinate values to a unit vector
function [c,ceq] = norm_vect(intc2)
global param

c=[];
for l = 1:35
% for l = param.k*6+1:length(intc2)
%     ceq(12*l-2 : 12*l) = 1 - sqrt(intc(12*l-2).^2 + intc(12*l-1).^2 + intc(12*l).^2);
    ceq(param.k*6+l) = 1 - sqrt(intc2(l).^2 + intc2(35+l).^2 + intc2(70+l).^2);
end


end