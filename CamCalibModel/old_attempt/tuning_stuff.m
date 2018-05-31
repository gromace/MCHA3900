qtransform = deg2rad([90;-90;90]);
rc = [0.211;0.0025;0.1115];
Tpose =[-0.6484;    0.0275;   -0.7608;     2.746;
        -0.0066;    0.9991;    0.0418;   -0.1787;
         0.7613;    0.0321;   -0.6477;     5.721;
         0;         0;         0;         1];
     
Tpose = [0.9998;    0.0196;    0.0047;  0.009465;
        -0.0195;    0.9996;   -0.0198;   0.08535;
        -0.0051;    0.0197;    0.9998;  0.006807;
         0;         0;         0;         1];  
     
intc = [0.0008;556.5421;587.7117;qtransform;rc;Tpose];

% intc = [0.0008;547.2651;652.3443;1.9475;-1.5866;2.2900;0.1935;0.0005;0.1869];

options = optimoptions(@fminunc,'MaxFunctionEvaluations',37000, 'PlotFcn', 'optimplotfval');
outcs = fminunc(@(intc) errorcalc(intc, imagePoints, worldPoints), intc, options)

[rHCc_projected, Tpose] = estval(outcs, worldPoints)


figure(3);clf
plot(rHCc_projected(1,:),rHCc_projected(2,:),'x-',imagePoints(:,1),imagePoints(:,2),'rx-')
% view(0,90)
for j=1:length(worldPoints)
    strnum(j) = {['',num2str(j)]};
end;clear j
text(rHCc_projected(1,:),rHCc_projected(2,:),strnum)
text(imagePoints(:,1),imagePoints(:,2),strnum);
legend('actual (r_{H_{ij}/C}^{c})','measured r_{H_{ij}/C}^{c}')
xlabel('u (px)','FontSize',fs)
ylabel('v (px)','FontSize',fs)
grid on

%%
function total_error = errorcalc(intc, imagePoints, worldPoints)
global param
% centre roguhly for image 1 in NED coords
qtransform = intc(4:6);
rc = intc(7:9);

Nc = rc(1)*ones(35,1);
Ec = worldPoints(:,1,param.n) - rc(2).*ones(length(worldPoints),1);
Dc = -worldPoints(:,2,param.n) + rc(3).*ones(length(worldPoints),1);
H = [worldPoints(:,1,param.n),worldPoints(:,2,param.n),zeros(length(worldPoints),1)];

for i = 1:length(worldPoints)

    % Clump parameters
    incs = [qtransform; H(i,1); H(i,2); Nc(i); Ec(i); Dc(i)];
    
    % Calculate Vector distances (rHNn, rHCc, Rch and RHn)
    [Ach, Anh, ~, Ach_norm] = forwardKinematicModel(incs);
    rH11Cn(:,i) = Anh(1:3,4);
    Rnh = Anh(1:3,1:3);  
    
    rHCc(:,i) = Ach(1:3,4);
    Rch = Ach(1:3,1:3);
    
    rHCc_norm(:,i) = Ach_norm(1:3,4);
%     rHCc(1,i) = -rHCc(1,i);
    pose = Rch*rHCc;

end

TT = [intc(10:13),intc(14:17),intc(18:21),intc(22:25)]';
C = CentralCamera('name','point grey camera','focal',intc(1),'pixel',4.8e-6,'resolution',[1024;1280],'centre',intc(2:3),'pose',TT);
rHCc_projected = C.project([-rHCc_norm(1,:);rHCc_norm(2,:);rHCc_norm(3,:)]);

total_error = immse(rHCc_projected,imagePoints')

end

%%
function [rHCc_projected,TTT] = estval(outcs, worldPoints)

global param
% centre roguhly for image 1 in NED coords
qtransform = outcs(4:6);
rc = outcs(7:9);

Nc = rc(1)*ones(35,1);
Ec = worldPoints(:,1,param.n) - rc(2).*ones(length(worldPoints),1);
Dc = -worldPoints(:,2,param.n) + rc(3).*ones(length(worldPoints),1);
H = [worldPoints(:,1,param.n),worldPoints(:,2,param.n),zeros(length(worldPoints),1)];

for i = 1:length(worldPoints)

    % Clump parameters
    incs = [qtransform; H(i,1); H(i,2); Nc(i); Ec(i); Dc(i)];
    
    % Calculate Vector distances (rHNn, rHCc, Rch and RHn)
    [Ach, Anh, ~, Ach_norm] = forwardKinematicModel(incs);
    rH11Cn(:,i) = Anh(1:3,4);
    Rnh = Anh(1:3,1:3);  
    
    rHCc(:,i) = Ach(1:3,4);
    Rch = Ach(1:3,1:3);
    
    rHCc_norm(:,i) = Ach_norm(1:3,4);
%     rHCc(1,i) = -rHCc(1,i);
    pose = Rch*rHCc;

end

TTT = [outcs(10:13),outcs(14:17),outcs(18:21),outcs(22:25)]';
C = CentralCamera('name','point grey camera','focal',outcs(1),'pixel',4.8e-6,'resolution',[1024;1280],'centre',outcs(2:3),'pose',TTT);
rHCc_projected = C.project([-rHCc_norm(1,:);rHCc_norm(2,:);rHCc_norm(3,:)]);

end

%% Vector to pixel

% 1. invert pixeltoVector 
% 2. Build Another LUT

Tpose = [Rch,ones(3,1);zeros(1,3),1];
Tpose = [-0.6484    0.0275   -0.7608     2.746;
         -0.0066    0.9991    0.0418   -0.1787;
          0.7613    0.0321   -0.6477     5.721;
          0         0         0         1];
Tpose =  [0.9998    0.0196    0.0047  0.009465;
         -0.0195    0.9996   -0.0198   0.08535;
         -0.0051    0.0197    0.9998  0.006807;
          0         0         0         1];      
     
C = CentralCamera('name','point grey camera','focal',0.000828471746583179,'pixel',4.8e-6,'resolution',[1024;1280],'centre',[556.542;587.711],'maxangle',deg2rad(190),'pose',Tpose);
% C = SphericalCamera('name','point grey camera','focal',0.000828471746583179,'pixel',4.8e-6,'resolution',[1024;1280],'centre',[556.542;587.711],'maxangle',deg2rad(190),'pose',Tpose);
rHCc_projected = C.project([-rHCc_norm(1,:);rHCc_norm(2,:);rHCc_norm(3,:)]);
% T = C.estpose([-rHCc_norm(1,:);rHCc_norm(2,:);rHCc_norm(3,:)],imagePoints')

figure(4);clf
plot(rHCc_projected(1,:),rHCc_projected(2,:),'x-',imagePoints(:,1),imagePoints(:,2),'rx-')
% view(0,90)
for j=1:length(worldPoints)
    strnum(j) = {['',num2str(j)]};
end;clear j
text(rHCc_projected(1,:),rHCc_projected(2,:),strnum)
text(imagePoints(:,1),imagePoints(:,2),strnum);
legend('measured (r_{H_{ij}/C}^{c})','actual r_{H_{ij}/C}^{c}')
xlabel('u (px)','FontSize',fs)
ylabel('v (px)','FontSize',fs)
grid on