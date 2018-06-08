function [err, ustar, uc, Ach] = px2vec3(in, O, imagePoints, num_images, u, v)
ImageGridCol = 7;       % x-direction propagation
ImageGridRow = 5;       % y-direction propagation

% Constant World points on checkerboard
rHCh = [O';zeros(1,length(O))];

% Initialise all the matrices to be filled
uc = zeros(length(O),3,length(num_images));
Rch = zeros(3,3,length(num_images));
rHCc = zeros(3,1,length(num_images));
Ach = zeros(4,4,length(num_images));
rbPCc = zeros(4,length(O),length(num_images));
rPCc = zeros(3,length(O),length(num_images));
rQCc = zeros(3,length(O),length(num_images));
d = zeros(length(O),length(num_images));

% Initialise Lerp grid
rx = ones(ImageGridRow,ImageGridCol);
ry = ones(ImageGridRow,ImageGridCol);
rz = ones(ImageGridRow,ImageGridCol);

for i=1:ImageGridRow
    for j=1:ImageGridCol
        rx(i,j) = in(6*num_images + i + ImageGridRow * (j - 1));
        ry(i,j) = in(6*num_images + 35 + i + ImageGridRow * (j - 1));
        rz(i,j) = in(6*num_images + 70 + i + ImageGridRow * (j - 1));
    end
end

% pixel2vector/lerp LUT to be updated
Fx = griddedInterpolant({u,v},rx,'linear','nearest');
Fy = griddedInterpolant({u,v},ry,'linear','nearest');
Fz = griddedInterpolant({u,v},rz,'linear','nearest');

for k = 1:num_images
    
    fx = Fx(imagePoints(:,2,k),imagePoints(:,1,k));
    fy = Fy(imagePoints(:,2,k),imagePoints(:,1,k));
    fz = Fz(imagePoints(:,2,k),imagePoints(:,1,k));

    % Vectorize
    uc(:,:,k) = [fx,fy,fz];
    
    % Rotation and direction vector in camera coordinates
    Rch(:,:,k) = eulerRotation(in(6*k - 5:6*k - 3));
    rHCc(:,:,k)  = in(6*k - 2:6*k);

    % Pose estimate
    Ach(:,:,k) =[Rch(:,:,k),rHCc(:,:,k);zeros(1,3),1];

    rbPCc(:,:,k) = Ach(:,:,k)*[rHCh;ones(1,length(O))];
    rPCc(:,:,k) = rbPCc(1:3,:,k);
    
    % Normalise predicted vectors
    norm_rPCc = sqrt(rPCc(1,:,k).^2 + rPCc(2,:,k).^2 + rPCc(3,:,k).^2);
    rQCc(:,:,k) = [rPCc(1,:,k)./norm_rPCc; rPCc(2,:,k)./norm_rPCc; rPCc(3,:,k)./norm_rPCc];        % 3 x 35

    % Compute angular error
    for i=1:length(O)
        d(i,k) = 1 - uc(i,:,k) * rQCc(:,i,k);
    end
     
    
end

% Update map
ustar = [in(6*num_images+1:6*num_images+35),in(6*num_images + 36:6*num_images+70),in(6*num_images+71:6*num_images+105)];

% Cost Function
err_p = sum(d, 2);
err = abs(sum(err_p, 1));
% err = lsqr(err_p, ones(length(O),1));

% err = immse(ustar', sum(rQCc, 3));

% err = abs(lsqr(sum(ustar, 2)./num_images, err_p));

end