function uc = pixeltovector1(u,v)

% theta = acos(upix*vpix);
slerp = @(t,upix,vpix) ((sin((1 - t).*acos(upix.*vpix))/sin(acos(upix.*vpix))).*upix + sin(t.*acos(upix.*vpix))/sin(acos(upix.*vpix))*vpix);

tu = (u(2) - u(1))./(u(3) - u(1));
tv = (v(2) - v(1))./(v(3) - v(1));

uac = slerp(tv,[u(1),v(1)],[u(1),v(3)]);
ubc = slerp(tv,[u(3),v(1)],[u(3),v(3)]);

uc = slerp(tu,uac,ubc);
