fs = 15;
CheckerboardDetection();
% theta = fmincon(@(x) engineModeClassifier(x,p),theta,[],[],Aeq,beq,lb,ub,[],fmopt);
worldPoints = worldPoints*1e-3;

in = [0.211,90,-90,90,524,544,190,0.0875,0.1115];
options = optimoptions(@fminunc,'MaxFunctionEvaluations',1500, 'PlotFcn', 'optimplotfval');
out = fminunc(@(in) camcalmodelopt(in, worldPoints, imagePoints), in, options)

[uv,rHCc_norm,rHCc] = camcalmodeltunetest(out,worldPoints,imagePoints);


%%
figure(45);clf
hold on
% plot(uv(1,:),uv(2,:),'bx',imagePoints(:,1),imagePoints(:,2),'rx',uverr(1,:),uverr(2,:),'mx')
plot(uv(1,:), uv(2,:), 'bx-', imagePoints(:,1), imagePoints(:,2), 'rx-')
text(imagePoints(1,1),imagePoints(1,2),'1: actual')
text(uv(1,1),uv(2,1),'1: predicted')
title('Error minimization: fminunc approach','FontSize',fs)
xlabel('u')
ylabel('v')
legend('Tuned estimated r_{H/C}^{c}', 'Actual r_{H/C}^{c}')
grid on

figure(1);clf
plot3(rHCc(1,:),rHCc(2,:),rHCc(3,:),'r+',0,0,0,'r+')
text(0,0,0,'CameraOrigin')
view(-145,-45)
for j=1:length(worldPoints)
    strnum(j) = {['',num2str(j)]};
end;clear j
text(rHCc(1,:),rHCc(2,:),rHCc(3,:),strnum);clear strnum
title('distance from cam to corner from cam perspective r_{H_{ij}/C}^{c}','FontSize',fs)
xlabel('c1 (m)','FontSize',fs)
ylabel('c2 (m)','FontSize',fs)
zlabel('c3 (m)','FontSize',fs)
grid on