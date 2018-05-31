function theta = TuningLikelihood_3(theta, modelType, p)


epsilon=1e-1;
lb = epsilon*[ones(1,2), zeros(1,3)];% TODO: sigma >= epsilon, P >= 0
ub = [ones(1,2)*inf, ones(1,3)]; % TODO: sigma <= inf, P <= 1

% Constrain sum of prior probabilities to one
Aeq =[ones(1,2), zeros(1,3)];
beq = 1;

switch modelType
    case 'binary'
    %Constrain overrun and null prior to zero
    Aeq = [Aeq; zeros(1,1),1,0;zeros(1,2),1]; % TODO
    beq = [beq; 0;0];  % TODO
    case 'ternary'
    %Constrain overrun prior to zero
    Aeq = [Aeq; zeros(1,5); zeros(1,5)]; % TODO
    beq = [beq; 0; 1];       % TODO
 end

fmopt = optimoptions('fmincon',...
    'Algorithm','sqp', ...
    'Display','iter', ...
    'PlotFcn',{@optimplotx,@optimplotfval}, ...
    'OutputFcn',@autotunePlotHelper ...
    );
theta = fmincon(@(x) Likelihood_3(x,p),theta,[],[],Aeq,beq,lb,ub,[],fmopt)