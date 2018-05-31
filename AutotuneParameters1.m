function [rQCc_est, Ach_est] = AutotuneParameters1(intc, worldPoints, ucn)

lowerbound = [-inf*ones(1,9),-inf*ones(1,3)];
upperbound = [];
Aeq = [zeros(1,9),ones(1,3)];
Beq = 1;

% options = optimoptions(@fminunc,'MaxFunctionEvaluations',3700, 'PlotFcn','optimplotfval','OptimalityTolerance',1e-9); 
% out = fminunc(@(intc) poseError(intc, worldPoints, ucn), intc, options);
options = optimoptions(@fmincon,'MaxFunctionEvaluations',3700, 'PlotFcn','optimplotfval','OptimalityTolerance',1e-10); 
out = fmincon(@(intc) poseError(intc, worldPoints, ucn), intc, [], [], Aeq, Beq, lowerbound, upperbound, [], options);

Rch_est = [out(1:3),out(4:6),out(7:9)];
rH11Cc_est = out(10:12);
Ach_est = [Rch_est,rH11Cc_est;zeros(1,3),1];

[~, rQCc_est] = poseError(out, worldPoints, ucn);
end

%% Pose estimation calculation
function [error_calc, rQCc] = poseError(in, O, ucn)

rHCh = zeros(3,length(O));
rQCc = zeros(3,length(O));
for i=1:length(O)
    rHCh(:,i) = [O(i,:)';0];
    
    Rch = [in(1:3),in(4:6),in(7:9)];
    rHCc = in(10:12);
    
    Ach =[Rch,rHCc;zeros(1,3),1];
    
    rbPCc = Ach*[rHCh(:,i);1];
    rPCc = rbPCc(1:3);

    norm_rPCc = sqrt(rPCc(1).^2 + rPCc(2).^2 + rPCc(3).^2);
    rQCc(:,i) = [rPCc(1)./norm_rPCc; rPCc(2)./norm_rPCc; rPCc(3)./norm_rPCc];

end

error_calc = immse(ucn, rQCc');

if ~isfinite(error_calc) || ~isreal(error_calc) || error_calc > 1 
    getSurprise
    delete(findall(0,'tag','TMWWaitbar'));
    error('SURPRISE SON!!: A surprising error was encountered while computing the optimized parameters.')
end

end