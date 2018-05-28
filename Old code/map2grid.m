%% Clean workspace
clear all; close all

tic;

%% Waitbar
delete(findall(0,'tag','TMWWaitbar'));

wh = waitbar(0,getMsg, ...
    'Name', 'MCHA3900 Project', ...
    'CreateCancelBtn', 'setappdata(gcbf,''cancelling'',1)');
%% Run Camera model
camcalibmodel;
waitbar(toc,wh); % Update waitbar
% close all
%% Find Checkerboard Corners   
% CheckerboardDetection()

% Image number and pixel to mm constant
n = 1;
p2m = 4.8e-6;
fs = 15;
%% Grid Sample Generation
ImageGridCol = 7;       % x-direction propagation
ImageGridRow = 5;       % y-direction propagation

start = 400;
finish = 860;

xstep = (finish - start)/ImageGridRow;
ystep = (finish - start)/ImageGridCol;

u = start:xstep:finish-1;
v = start:ystep:finish-1;

[u_grid,v_grid] = ndgrid(u,v);

u1 = linspace(start,finish,length(imagePoints(:,:,n)));
v1 = linspace(start,finish,length(imagePoints(:,:,n)));
%% Sort selected image points into a grid
imax = ones(ImageGridRow,ImageGridCol);
imay = ones(ImageGridRow,ImageGridCol);
rx = ones(ImageGridRow,ImageGridCol);
ry = ones(ImageGridRow,ImageGridCol);
rz = ones(ImageGridRow,ImageGridCol);

for i=1:ImageGridRow
    for j=1:ImageGridCol
        imax(i,j) = imagePoints(j + ImageGridRow * (i - 1),1,n);
        imay(i,j) = imagePoints(j + ImageGridRow * (i - 1),2,n);
        rx(i,j) = rHCc(1,i + ImageGridRow * (j - 1));
        ry(i,j) = rHCc(2,i + ImageGridRow * (j - 1));
        rz(i,j) = rHCc(3,i + ImageGridRow * (j - 1));
    end
end

%% Interpolant between surfaces (lerp): pixel to vector
Fx = griddedInterpolant({u,v},rx,'linear','nearest');
Fy = griddedInterpolant({u,v},ry,'linear','nearest');
Fz = griddedInterpolant({u,v},rz,'linear','nearest');

fx = Fx(imagePoints(:,2),imagePoints(:,1));
fy = Fy(imagePoints(:,2),imagePoints(:,1));
fz = Fz(imagePoints(:,2),imagePoints(:,1));

z = imagePoints(:,1).^2 + imagePoints(:,2).^2;

% uc_norm = 1 - fx(:).^2 - fy(:).^2 - fz(:).^2;
uc_norm = fx(:).^2 + fy(:).^2 + fz(:).^2;

uc = [-fx,fy,fz];

% Normalise the sucker... I mean vector
ucn = [uc(:,1)./uc_norm, uc(:,2)./uc_norm, uc(:,3)./uc_norm];

%% How's the waitbar going bois?
try 
catch hot_potato
    delete(wh); % Remove waitbar if error
    rethrow(hot_potato); % Someone else's problem now
end
waitbar(toc,wh); % Update waitbar
delete(wh); % Remove waitbar if we complete successfully
%% Plot
figure(55);clf
plot3(ucn(:,1),ucn(:,2),ucn(:,3),'x-',0,0,0,'o',-rHCc_norm(1,:),rHCc_norm(2,:),rHCc_norm(3,:),'rx-')
% view(0,90)
for j=1:length(worldPoints)
    strnum(j) = {['',num2str(j)]};
end;clear j
text(ucn(:,1),ucn(:,2),ucn(:,3),strnum)
text(0,0,0,'CamOrigin')
text(-rHCc_norm(1,:),rHCc_norm(2,:),rHCc_norm(3,:),strnum);
legend('pixeltovec (u^{c}_{ij})','measured r_{H_{ij}/C}^{c}')
xlabel('c1 (m)','FontSize',fs)
ylabel('c2 (m)','FontSize',fs)
zlabel('c3 (m)','FontSize',fs)
grid on

figure(35);clf
plot(ucn(:,1),ucn(:,2),'x-',-rx,ry,'o-')
for j=1:length(worldPoints)
    strnum(j) = {['',num2str(j)]};
end;clear j
text(ucn(:,1),ucn(:,2),strnum)
text(-rHCc(1,:),rHCc(2,:),strnum)
xlabel('u (px)','FontSize',fs)
ylabel('v (px)','FontSize',fs)
grid on