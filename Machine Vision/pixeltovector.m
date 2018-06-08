function out = pixeltovector(u,v)
    % Initial image pose and pixel to vector grid
    load('optimized_pixelToVector_lerp_grid.mat');
    load('pixelToVector_lerp_grid.mat');

    % From worldPoints
    num_images = 1;

    for k = 1:num_images

        % Non-optimised px2vect/lerp LUT
        fx = Fx(u,v);
        fy = Fy(u,v);
        fz = Fz(u,v);

        % Vectorize
        uc = [-fx,fy,fz];

        % Normalise
        uc_norm = sqrt(fx(:).^2 + fy(:).^2 + fz(:).^2);
        ucn(:,:,k) = [uc(:,1)./uc_norm, uc(:,2)./uc_norm, uc(:,3)./uc_norm];

        % Optimised px2vect/lerp LUT
        fxStar = Fxstar(u,v);
        fyStar = Fystar(u,v);
        fzStar = Fzstar(u,v);

        % Vectorize
        uc_star = [-fxStar,fyStar,fzStar];

        % Normalise the sucker... I mean vector
        uc_norm_star = sqrt(fxStar(:).^2 + fyStar(:).^2 + fzStar(:).^2);

        ucn_star(:,:,k) = [uc_star(:,1)./uc_norm_star, uc_star(:,2)./uc_norm_star, uc_star(:,3)./uc_norm_star];
    end
    out = [ucn, ucn_star];
end
