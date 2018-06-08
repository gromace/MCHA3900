%% Initialise and set up parameter stucture
clear all;

global param
%% Waitbar
delete(findall(0,'tag','TMWWaitbar'));

wh = waitbar(0,getMsg, ...
    'Name', 'MCHA3900 Project', ...
    'CreateCancelBtn', 'setappdata(gcbf,''cancelling'',1)');
%% Find checker board corners
CheckerboardDetection();
waitbar(0.25, wh); % Update waitbar

% Image number
param.n = 1;
fs = 15;

figure(4567);clf
imshow(imageFileNames{param.n})

%% Parameters
param.p2m = 4.8e-6;

% Initial angles to rotate matrices
qtransform = deg2rad([90;-90;90]);

% centre roguhly for image 1 in NED coords
% rc = [0.211;0.0875;0.1115];
rc = [0.211;0.0025;0.1115];

Nc = rc(1)*ones(35,1);
Ec = worldPoints(:,1) - rc(2).*ones(length(worldPoints),1);
Dc = -worldPoints(:,2) + rc(3).*ones(length(worldPoints),1);
H = [worldPoints(:,1),worldPoints(:,2),zeros(length(worldPoints),1)];

%% Sim 'Ray Cast'
for i = 1:length(worldPoints)
    
    % Clump parameters
    in = [qtransform; H(i,1); H(i,2); Nc(i); Ec(i); Dc(i)];
    
    % Calculate Vector distances (rHNn, rHCc, Rch and RHn)
    [Ach, Anh, ~, Ach_norm] = forwardKinematicModel(in);
    rH11Cn(:,i) = Anh(1:3,4);
    Rnh = Anh(1:3,1:3);  
    
    rHCc(:,i) = Ach(1:3,4);
    Rch = Ach(1:3,1:3);
    
    % Normalised pose
    rHCc_norm(:,i) = Ach_norm(1:3,4);
%     rHCc(1,i) = -rHCc(1,i);
    pose = Rch*rHCc;
    waitbar(0.25+0.25*(i/length(worldPoints)),wh); % Update waitbar
end

%% How's the waitbar going bois?
try 
catch hot_potato
    delete(wh); % Remove waitbar if error
    rethrow(hot_potato); % Someone else's problem now
end
waitbar(1,wh); % Update waitbar
close
delete(wh); % Remove waitbar if we complete successfully

%% Plots
figure(2);clf
plot3(0,0,0,'o',-rHCc_norm(1,:),rHCc_norm(2,:),rHCc_norm(3,:),'rx-')
% view(0,90)
for j=1:length(worldPoints)
    strnum(j) = {['',num2str(j)]};
end;clear j
text(0,0,0,'CamOrigin')
text(-rHCc_norm(1,:),rHCc_norm(2,:),rHCc_norm(3,:),strnum);
title('Normalised Camera view r_{Q_{ij}/C}^{c}','FontSize',fs)
% legend('pixeltovec (u^{c}_{ij})','measured r_{H_{ij}/C}^{c}')
xlabel('c1 (unit)','FontSize',fs)
ylabel('c2 (unit)','FontSize',fs)
zlabel('c3 (unit)','FontSize',fs)
grid on

figure(3);clf
% plot3(rHCc(1,:),rHCc(2,:),rHCc(3,:),'r+',0,0,0,'r+',rHCc_tuned(1,:),rHCc_tuned(2,:),rHCc_tuned(3,:),'b+')
plot3(-rHCc(1,:),rHCc(2,:),rHCc(3,:),'r+-',0,0,0,'r+')
text(0,0,0,'CameraOrigin')
view(-145,-45)
for j=1:length(worldPoints)
    strnum(j) = {['',num2str(j)]};
end;clear j
text(-rHCc(1,:),rHCc(2,:),rHCc(3,:),strnum);
% text(rHCc_tuned(1,:),rHCc_tuned(2,:),rHCc_tuned(3,:),strnum);clear strnum
title('distance from cam to corner from cam perspective r_{H_{ij}/C}^{c}','FontSize',fs)
xlabel('c1 (m)','FontSize',fs)
ylabel('c2 (m)','FontSize',fs)
zlabel('c3 (m)','FontSize',fs)
grid on

% figure(5);clf
% plot3(rHCc_est(1,:),rHCc_est(2,:),rHCc_est(3,:),'rx-')
% for j=1:length(worldPoints)
%     strnum(j) = {['',num2str(j)]};
% end;clear 
% text(rHCc_est(1,:),rHCc_est(2,:),rHCc_est(3,:),strnum);
% legend('est','actual')
% grid on