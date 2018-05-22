%% Clean workspace
clear all; close all

%% Find Checkerboard Corners   
CheckerboardDetection()

% Image number and pixel to mm constant
n = 1;
p2m = 4.8e-6;

%% Grid Sample Generation
ImageGridCol = 5;
ImageGridRow = 7;

start = 400;
finish = 860;

xstep = (finish - start)/ImageGridRow;
ystep = (finish - start)/ImageGridCol;

xgrid = start:xstep:finish-1;
ygrid = start:ystep:finish-1;

[u,v] = ndgrid(xgrid,ygrid);

%% Sort selected image points into a grid
imax = ones(ImageGridRow,ImageGridCol);
imay = ones(ImageGridRow,ImageGridCol);

for i=1:ImageGridCol
    for j=1:ImageGridRow
%         imax(j,i) = x(j + ImageGridRow * i - ImageGridRow);
%         imay(j,i) = y(j + ImageGridRow * i - ImageGridRow);
        imax(j,i) = imagePoints(j + ImageGridRow * i - ImageGridRow,1,n);
        imay(j,i) = imagePoints(j + ImageGridRow * i - ImageGridRow,2,n);
    end
end
ima_norm = sqrt(imagePoints(:,1,n).^2+imagePoints(:,2,n).^2);
% imax(1:7,1) = x(1:7);
% imax(1:7,2) = x(8:14);
% imax(1:7,3) = x(15:21);
% imax(1:7,4) = x(22:28);
% imax(1:7,5) = x(29:35);
% 
% imay(1:7,1) = y(1:7);
% imay(1:7,2) = y(8:14);
% imay(1:7,3) = y(15:21);
% imay(1:7,4) = y(22:28);
% imay(1:7,5) = y(29:35);

%% Create Gridded Interpolant
Fx = griddedInterpolant(u,v,imax,'linear','nearest');
Fy = griddedInterpolant(u,v,imay,'linear','nearest');

r = [640,520,21];

Frx = Fx(r(1),r(2));
Fry = Fy(r(1),r(2));

%% Plots
figure(2);clf
imshow(imread(imageFileNames{n}))
hold on
plot(imagePoints(:,1,n),imagePoints(:,2,n),'r+')
for i=1:length(worldPoints)
    str(i) = {['',num2str(i)]};
end
text(imagePoints(:,1,n),imagePoints(:,2,n),str')
grid on
xlim([0 1280])
ylim([0 1024])
hold on
plot(640,512,'ro')

figure(3);clf
plot(u,v,'s',imax,imay,'x')
xlim([350,860])
ylim([350,860])
hold on
plot(Frx,Fry,'o')
grid on

figure(5);clf
subplot(2,1,1)
plot(imagePoints(:,1,n)./ima_norm,imagePoints(:,2,n)./ima_norm,'x')
title('Normalized Vector Plots,r_{H/C}^{C}/||r_{H/C}||')
xlabel('pixels')
ylabel('pixels')
grid on 

subplot(2,1,2)
plot(p2m*(imagePoints(:,1,n)./ima_norm),p2m*(imagePoints(:,2,n)./ima_norm),'x')
xlabel('mm')
ylabel('mm')
grid on