R0 = eulerRotation([0;0;deg2rad(180)]);%*eulerRotation([deg2rad(180);0;0]);
Tpose0 = [R0,zeros(3,1);zeros(1,3),1];
Tpose = [Rch,rHCc(:,1);zeros(1,3),1];

C = CatadioptricCamera(...
    'name','Point Grey BlackFly',...
    'focal',1e-5,'centre',[524,544]',...
    'maxangle',deg2rad(190),'pixel',4.8e-6,...
    'resolution',[1024 1280]);%,'pose',Tpose0);
% C.pp = imagePoints(1,:,n)';
% uv = C.project([-rHCc(1,:);rHCc(2,:);rHCc(3,:)]);
uv = C.project([-rHCc_norm(1,:);rHCc_norm(2,:);rHCc_norm(3,:)]);
uverr = (imagePoints(:,:,n)' - uv).^2;

for i=1:length(worldPoints)
    thetahat(i) = acos(uv(1,i)*uv(2,i));
    thetatilda(i) = acos(imagePoints(i,1,n)*imagePoints(i,2,n));
end

% Plots
figure(45);clf
% plot(uv(1,:),uv(2,:),'bx',imagePoints(:,1),imagePoints(:,2),'rx',uverr(1,:),uverr(2,:),'mx')
plot(uv(1,:),uv(2,:),'bx',imagePoints(:,1),imagePoints(:,2),'rx')
% plot(uv(1,1),uv(2,1),'bx',imagePoints(1,1),imagePoints(1,2),'rx')
text(imagePoints(1,1),imagePoints(1,2),'1')
text(uv(1,1),uv(2,1),'1')
xlabel('u (px)','FontSize',fs)
ylabel('v (px)','FontSize',fs)
title('Projected image from vector to pixel','FontSize',fs)
legend('estimated r_{H/C}^{c}','Actual r_{H/C}^{c}')
grid on

%% Least squares method: estimated vs observed data
thetaerr = lsqr(thetahat',thetatilda')

errest_x = 2.5*(lsqr(imagePoints(:,1),uv(1,:)'))
errest_y = 2*(lsqr(imagePoints(:,2),uv(2,:)'))

uvxest = errest_x*(uv(1,:)) + (imagePoints(1,1)'-errest_x*uv(1,1)); 
uvyest = errest_y*(uv(2,:)) + (imagePoints(1,2)'-errest_y*uv(2,1));
                                                                          
% Plots
figure(46);clf
% plot(errest_x*uv(1,:),errest_y*uv(2,:),'bx',imagePoints(:,1),imagePoints(:,2),'rx',uverr(1,:),uverr(2,:),'mx')
plot(uvxest,uvyest,'bx-',imagePoints(:,1),imagePoints(:,2),'rx-')
text(imagePoints(1,1),imagePoints(1,2),'1')
text(uvxest(1,1),uvyest(1,1),'1')
title('Least Squares tuning','FontSize',fs)
xlabel('u (px)','FontSize',fs)
ylabel('v (px)','FontSize',fs)
legend('estimated r_{H/C}^{c}','Actual r_{H/C}^{c}')
grid on

%% Est Waste stuff
% uRxyz =[ ...
%        rz*(sin(phi)*sin(psi) + cos(phi)*cos(psi)*sin(theta)) - ry*(cos(phi)*sin(psi) - cos(psi)*sin(phi)*sin(theta)) + rx*cos(psi)*cos(theta);
%        ry*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta)) - rz*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)) + rx*cos(theta)*sin(psi);
%                                                                               rz*cos(phi)*cos(theta) - rx*sin(theta) + ry*cos(theta)*sin(phi)];
% % Forward Kinamatic
% Rch = [...
%        cos(q1)*cos(q2)^2*cos(q3) - sin(q1)*sin(q3) - cos(q1)*cos(q3)*sin(q2)^2, cos(q1)*sin(q2)^2*sin(q3) - cos(q1)*cos(q2)^2*sin(q3) - cos(q3)*sin(q1), 2*cos(q1)*cos(q2)*sin(q2);
%        cos(q1)*sin(q3) + cos(q2)^2*cos(q3)*sin(q1) - cos(q3)*sin(q1)*sin(q2)^2, cos(q1)*cos(q3) - cos(q2)^2*sin(q1)*sin(q3) + sin(q1)*sin(q2)^2*sin(q3), 2*cos(q2)*sin(q1)*sin(q2);
%                                                    -2*cos(q2)*cos(q3)*sin(q2),                                               2*cos(q2)*sin(q2)*sin(q3),     cos(q2)^2 - sin(q2)^2];
%                                                
% rHCc =[...
%        lH11Cx*cos(q1)*cos(q2) - Hx*(sin(q1)*sin(q3) - cos(q1)*cos(q2)^2*cos(q3) + cos(q1)*cos(q3)*sin(q2)^2) - Hy*(cos(q3)*sin(q1) + cos(q1)*cos(q2)^2*sin(q3) - cos(q1)*sin(q2)^2*sin(q3)) - lH11Cy*sin(q1) + lH11Cz*cos(q1)*sin(q2);
%        lH11Cy*cos(q1) + Hx*(cos(q1)*sin(q3) + cos(q2)^2*cos(q3)*sin(q1) - cos(q3)*sin(q1)*sin(q2)^2) + Hy*(cos(q1)*cos(q3) - cos(q2)^2*sin(q1)*sin(q3) + sin(q1)*sin(q2)^2*sin(q3)) + lH11Cx*cos(q2)*sin(q1) + lH11Cz*sin(q1)*sin(q2);
%                                                                                                                                         lH11Cz*cos(q2) - lH11Cx*sin(q2) - 2*Hx*cos(q2)*cos(q3)*sin(q2) + 2*Hy*cos(q2)*sin(q2)*sin(q3)];