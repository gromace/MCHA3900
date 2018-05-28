% Mercator projection
% Given a "mapping sphere" of radius R, for a unit sphere R=1
% the Mercator projection (x,y) of a given latitude and longitude is:
R = 1;   
x = R * longitude;
y = R * log(tan((latitude + pi/2)/2));

% and the inverse mapping of a given map location (x,y) is:
longitude = x / R;
latitude = 2 * atan(exp(y/R)) - pi/2;

% Given longitude and latitude on a sphere of radius S,
% the 3D coordinates P = (P.x, P.y, P.z) are:
S = R;
P.x = S * cos(latitude) * cos(longitude);
P.y = S * cos(latitude) * sin(longitude);
P.z = S * cos(latitude);