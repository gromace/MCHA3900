%% 1D Interpolant
x1d=1:1:10;
y1d=[4 5 8 2 5 7 1 9 10 6];
f = griddedInterpolant(x1d,y1d,'linear','nearest');

xd1d = 1:0.01:10;
yd = f(xd1d);

% Plots
figure(20);clf
plot(x1d,y1d,'o')
hold on
plot(xd1d,yd,'-')
legend('Samples data','Linear Interpolent')

%% 2D Interpolant
[x2d,y2d] = ndgrid(-5:1:5,-25:1:25);
z2d = 1 - x2d.^2 - y2d.^2;
f2d = griddedInterpolant(x2d,y2d,z2d,'linear','nearest');

[xd2d,yd2d] = ndgrid(-5:0.5:5,-5:0.5:5);
zd2d = f2d(xd2d,yd2d);

% Plots
figure(21);clf
surf(x2d,y2d,z2d)
grid on
view(60,60)
hold on
plot3(xd2d,yd2d,zd2d,'x')
title('sample data')
%legend('Sample Distribution data','Interpolant data')
%% 1D Excercise
f = @(x) (x-3).^2;

x_true = linspace(0,6,100);
f_true = f(x_true);

x_known = [1 2 3 4 5];
f_known = f(x_known);

f_linear_interp_func = griddedInterpolant(x_known,f_known,'linear','nearest');
f_linear_interp = f_linear_interp_func(x_true);

figure(22);clf
plot(x_true,f_true,'x',x_known,f_known,'x',x_true,f_linear_interp,'x')
legend('True','Known','Interpolated Data')

%% Let's just give the actual image a fair go, shall we?
[x,y] = ndgrid(1:1:1024, 1:1:1280);

[u,v] = ndgrid(imagePoints(:,1), imagePoints(:,2));

xa = linspace(1,1024,1024);
ya = linspace(1,1280,1280);

V = nan(length(xa),length(ya));

imx = sort(imagePoints(:,1));
imy = sort(imagePoints(:,2));

F = griddedInterpolant({imx,imy},u*v,'linear','nearest');

z = F(x,y);

% F = griddedInterpolant(x,y,z,'linear','nearest');
imagePoints(:,1); 
imagePoints(:,2);

plot(x(1:100:end,1:100:end),y(1:100:end,1:100:end),'x',u(:,1),v(1,:),'o')
title('Some grid with points and samples')
grid on