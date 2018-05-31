% Find checkerboard corners
CheckerboardDetection();
im_num = 10;

% Initial image pose and pixel to vector grid
load('Initial_image_pose.mat')
load('pixelToVector_lerp_grid.mat');

Ach_est(:,:,1) = Ach_init_est;
intc = [Ach_est(1:3,1,1);Ach_est(1:3,2,1);Ach_est(1:3,3,1);Ach_est(1:3,4,1)]; 
rQCc_est = zeros(3,35);
usc_est = zeros(35,3);

for j = 2:length(imagesUsed)
    intc = [Ach_est(1:3,1);Ach_est(1:3,2);Ach_est(1:3,3);Ach_est(1:3,4)];
     
    % px2vect/lerp LUT
    fx = Fx(imagePoints(:,2,j),imagePoints(:,1,j));
    fy = Fy(imagePoints(:,2,j),imagePoints(:,1,j));
    fz = Fz(imagePoints(:,2,j),imagePoints(:,1,j));
    
    % Vectorize
    uc = [-fx,fy,fz];

    % Normalise the sucker... I mean vector
    uc_norm = sqrt(fx(:).^2 + fy(:).^2 + fz(:).^2);
    ucn = [uc(:,1)./uc_norm, uc(:,2)./uc_norm, uc(:,3)./uc_norm];
    ucn_est = usc_est + ucn;
    
    % Calibration
    [temp_rQCc_est(:,:,j), Ach_est] = AutotuneParameters2(intc, worldPoints, ucn);
    
    rQCc_est = rQCc_est + temp_rQCc_est(:,:,j);
    
end
% ucn_est = ucn_est./length(imagesUsed);
rQCc_est = rQCc_est./length(imagesUsed);
%% Plots
figure(44);clf
for i=im_num
    plot3(0,0,0,'o',-temp_rQCc_est(1,:,i),temp_rQCc_est(2,:,i),temp_rQCc_est(3,:,i),'x-')
    % view(0,90)
    for j=1:length(worldPoints)
        strnum(j) = {['',num2str(j)]};
    end;clear j
    text(-temp_rQCc_est(1,:,i),temp_rQCc_est(2,:,i),temp_rQCc_est(3,:,i),strnum)
    text(0,0,0,'CamOrigin')
    hold on
end
legend('pixeltovec (u^{c}_{ij})','measured r_{H_{ij}/C}^{c}')
xlabel('c1 (unit)','FontSize',20)
ylabel('c2 (unit)','FontSize',20)
zlabel('c3 (unit)','FontSize',20)
grid on

figure(45);clf
plot3(-ucn_est(:,1),ucn_est(:,2),ucn_est(:,3),'x-',0,0,0,'o',-rQCc_est(1,:),rQCc_est(2,:),rQCc_est(3,:),'rx-')
% view(0,90)
for j=1:length(worldPoints)
    strnum(j) = {['',num2str(j)]};
end;clear j
text(-ucn_est(:,1),ucn_est(:,2),ucn_est(:,3),strnum)
text(0,0,0,'CamOrigin')
text(-rQCc_est(1,:),rQCc_est(2,:),rQCc_est(3,:),strnum);
legend('pixeltovec (u^{c}_{ij})','measured r_{H_{ij}/C}^{c}')
xlabel('c1 (unit)','FontSize',20)
ylabel('c2 (unit)','FontSize',20)
zlabel('c3 (unit)','FontSize',20)
grid on

% figure('Name',['Calibration Image ',num2str(im_num)],'NumberTitle','off');clf
figure(46);clf
imshow(imageFileNames{im_num})