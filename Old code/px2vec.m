function [total_error, o] = px2vec(in, imagePoints, worldPoints)

rc_meas = in(1:3);
qtransform_meas = in(4:6);


% Measurement model of checkerboard in space
[rHCc_meas, ~, Rch] = CamMeasurementModel(rc_meas, qtransform_meas, worldPoints);

% Image number and pixel to mm constant
n = 1;

%% Grid Sample Generation
ImageGridCol = 7;       % x-direction propagation
ImageGridRow = 5;       % y-direction propagation

start = 400;
finish = 860;

xstep = (finish - start)/ImageGridRow;
ystep = (finish - start)/ImageGridCol;

u = start:xstep:finish-1;
v = start:ystep:finish-1;

% [u_grid,v_grid] = ndgrid(u,v);

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
        rx(i,j) = rHCc_meas(1,i + ImageGridRow * (j - 1));
        ry(i,j) = rHCc_meas(2,i + ImageGridRow * (j - 1));
        rz(i,j) = rHCc_meas(3,i + ImageGridRow * (j - 1));
    end
end

%% Interpolant between surfaces (lerp): pixel to vector
Fx = griddedInterpolant({u,v},rx,'linear','nearest');
Fy = griddedInterpolant({u,v},ry,'linear','nearest');
Fz = griddedInterpolant({u,v},rz,'linear','nearest');

fx = Fx(imagePoints(:,2),imagePoints(:,1));
fy = Fy(imagePoints(:,2),imagePoints(:,1));
fz = Fz(imagePoints(:,2),imagePoints(:,1));

% uc_norm = 1 - fx(:).^2 - fy(:).^2 - fz(:).^2;
uc_norm = fx(:).^2 + fy(:).^2 + fz(:).^2;

uc = [-fx,fy,fz];

% Normalise the sucker... I mean vector
ucn = [uc(:,1)./uc_norm, uc(:,2)./uc_norm, uc(:,3)./uc_norm];

% Compute Mean-Squared error
total_error = immse(rHCc_meas',ucn)

if ~isfinite(total_error) || ~isreal(total_error) || total_error > 1e1 
    getSurprise
    error('SURPRISE SON!!: A surprising error was encountered while computing the optimized parameters.')
end