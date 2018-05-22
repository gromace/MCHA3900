
%% Create a 2D Grideded Interpolant dataset
[u_samp,v_samp] = ndgrid(400:1:800,400:1:800);

fx_samp = griddedInterpolant(u_samp,v_samp,rHCc(1,:),'linear','nearest');
fy_samp = griddedInterpolant(u_samp,v_samp,rHCc(2,:),'linear','nearest');
fz_samp = griddedInterpolant(u_samp,v_samp,rHCc(3,:),'linear','nearest');

frx = fx_samp(imagePoints);
fry = fy_samp(imagePoints);
frz = fz_samp(imagePoints);

figure(21);clf
surf(frx,fry,frz)
grid on
view(60,60)
% hold on
% plot3(xd2d,yd2d,zd2d,'x')
% title('sample data')
%legend('Sample Distribution data','Interpolant data')