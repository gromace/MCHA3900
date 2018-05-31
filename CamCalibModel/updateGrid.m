function [Fxstar, Fystar, Fzstar] = updateGrid(ustar)
%% Grid Sample Generation
ImageGridCol = 7;       % x-direction propagation
ImageGridRow = 5;       % y-direction propagation
n = 1;

start = 400;
finish = 860;

xstep = (finish - start)/ImageGridRow;
ystep = (finish - start)/ImageGridCol;

u = start:xstep:finish-1;
v = start:ystep:finish-1;

%% Sort selected image points into a grid
ucx = ones(ImageGridRow,ImageGridCol);
ucy = ones(ImageGridRow,ImageGridCol);
ucz = ones(ImageGridRow,ImageGridCol);

for i=1:ImageGridRow
    for j=1:ImageGridCol
        ucx(i,j) = ustar(1,i + ImageGridRow * (j - 1));
        ucy(i,j) = ustar(2,i + ImageGridRow * (j - 1));
        ucz(i,j) = ustar(3,i + ImageGridRow * (j - 1));
    end
end

%% Interpolant between surfaces (lerp): pixel to vector
Fxstar = griddedInterpolant({u,v},ucx,'linear','nearest');
Fystar = griddedInterpolant({u,v},ucy,'linear','nearest');
Fzstar = griddedInterpolant({u,v},ucz,'linear','nearest');