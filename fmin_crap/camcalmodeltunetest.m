function [uv,rHCc_norm,rHCc] = camcalmodeltunetest(in,worldPoints,imagePoints)
rcz = in(1);
q1 = in(2);
q2 = in(3);
q3 = in(4);
ctpt1 = in(5);
ctpt2 = in(6);
camangle = in(7);
rcx = in(8);
rcy = in(9);
%% Image processing
% TODO: load and detect checkerboard points
n = 1;
fs = 15;
% CheckerboardDetection();

% convert from mm to m
% worldPoints(:,:,n) = worldPoints(:,:,n)*1e-3;

%% Parameters
global param

param.p2m = 4.8e-6;

% centre roguhly for image 1 in NED coords
% rc = [rcz;0.0875;0.1115];
rc = [0.211,rcx,rcy];
% rc = [0.211;0.0025;0.1115];

Nc = rc(1)*ones(35,1);
Ec = worldPoints(:,1,n) - rc(2).*ones(length(worldPoints),1);
Dc = -worldPoints(:,2,n) + rc(3).*ones(length(worldPoints),1);
H = [worldPoints(:,1,n),worldPoints(:,2,n),zeros(length(worldPoints),1)];

%% Sim 'Ray Cast'
for i = 1:length(worldPoints)
    param.Hx = H(i,1);
    param.Hy = H(i,2);
    param.lH11Cx = Nc(i);
    param.lH11Cy = Ec(i);
    param.lH11Cz = Dc(i);

    qtransform = deg2rad([q1;q2;q3]);
    
    % Calculate Vector distances (rHNn and RHn)
    [Ach, Anh, ~] = forwardKinematicModel(qtransform);
    rH11Cn(:,i) = Anh(1:3,4);
    Rnh = Anh(1:3,1:3);  
    
    rHCc(:,i) = Ach(1:3,4);
    Rch = Ach(1:3,1:3);
    
    rHCc_norm(:,i) = param.rHCc_norm;
    pose = Rch*rHCc;
end
%% Camera object: vec to px
C = CatadioptricCamera(...
    'name','Point Grey BlackFly',...
    'focal',1e-5,'centre',[ctpt1,ctpt2],...
    'maxangle',deg2rad(camangle),'pixel',4.8e-6,...
    'resolution',[1024 1280]);%,'pose',Tpose0);
% C.pp = imagePoints(1,:,n)';
% uv = C.project([-rHCc(1,:);rHCc(2,:);rHCc(3,:)]);
uv = C.project([-rHCc_norm(1,:);rHCc_norm(2,:);rHCc_norm(3,:)]);
uverr = (imagePoints(:,:,n)' - uv).^2;
    
for i=1:length(worldPoints)
    thetahat(i) = acos(uv(1,i)*uv(2,i));
    thetatilda(i) = acos(imagePoints(i,1,n)*imagePoints(i,2,n));
end

