function [err, ustar, ucn, Ach] = px2vec2(in, O, imagePoints, num_images, Fx, Fy, Fz)
% Constant World points on checkerboard
rHCh = [O';zeros(1,length(O))];

% Initialise all the matrices to be filled
ustar = zeros(35,3);
uc = zeros(35,3,num_images);
ucn = zeros(length(O),3,length(num_images));
Rch = zeros(3,3,length(num_images));
rHCc = zeros(3,1,length(num_images));
Ach = zeros(4,4,length(num_images));
rbPCc = zeros(4,length(O),length(num_images));
rPCc = zeros(3,length(O),length(num_images));
rQCc = zeros(3,length(O),length(num_images));
d = zeros(length(O),length(num_images));

for k = 1:num_images
    
    % pixel2vector/lerp LUT
    fx = Fx(imagePoints(:,2,k),imagePoints(:,1,k));
    fy = Fy(imagePoints(:,2,k),imagePoints(:,1,k));
    fz = Fz(imagePoints(:,2,k),imagePoints(:,1,k));

    % Vectorize
    uc(:,:,k) = [-fx,fy,fz];
%     ucn(:,:,k) = [-fx,fy,fz];
    
    % Normalise 
    uc_norm = sqrt(fx(:).^2 + fy(:).^2 + fz(:).^2);
    ucn(:,:,k) = [uc(:,1)./uc_norm, uc(:,2)./uc_norm, uc(:,3)./uc_norm];                     % 35 x 3
    
    % Rotation and direction vector in camera coordinates
    Rch(:,:,k) = eulerRotation(in(6*k - 5:6*k - 3));
    rHCc(:,:,k)  = in(6*k - 2:6*k);
%     Rch(:,:,k)  = [in(12*(k)-11 : 12*(k)-9), in(12*(k)-8 : 12*(k) - 6),in(12*(k)-5 : 12*(k)-3)];
%     rHCc(:,:,k)  = in(12*(k)-2 : 12*(k));

    % Pose estimate
    Ach(:,:,k) =[Rch(:,:,k),rHCc(:,:,k);zeros(1,3),1];

    rbPCc(:,:,k) = Ach(:,:,k)*[rHCh;ones(1,length(O))];
    rPCc(:,:,k) = rbPCc(1:3,:,k);
    
    % Normalise predicted vectors
    norm_rPCc = sqrt(rPCc(1,:,k).^2 + rPCc(2,:,k).^2 + rPCc(3,:,k).^2);
    rQCc(:,:,k) = [rPCc(1,:,k)./norm_rPCc; rPCc(2,:,k)./norm_rPCc; rPCc(3,:,k)./norm_rPCc];        % 3 x 35
    
    % Compute angular error
    for i=1:length(O)
        d(i,k) = 1 - ucn(i,:,k) * rQCc(:,i,k);      
    end
    
    % Update map
    ustar = ustar + ucn(:,:,k);
end

% NOTE: not sure about the error part here
err_p = sum(d, 2);
% err = sum(err_p, 1);

err = abs(lsqr(sum(ustar, 2)./num_images, err_p));

end