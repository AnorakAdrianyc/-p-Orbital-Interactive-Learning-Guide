function Y = realY(name, x, y, z)
% REALY Real spherical harmonics (normalized on the unit sphere).
%
% Y = orb.realY(name, x, y, z) evaluates the real angular function at
% Cartesian coordinates. name is one of:
%   s
%   px, py, pz
%   dz2, dxz, dyz, dxy, dx2-y2
%   fz3, fxz2, fyz2, fxyz, fz(x2-y2), fx(x2-3y2), fy(3x2-y2)
%
% These are the real combinations of Y_l^m used in chemistry (Beiser 6.7
% angular forms for p and d; l = 3 is the same construction for 4f).

name = lower(strtrim(name));
r = sqrt(x.^2 + y.^2 + z.^2);
ok = r > 0;
nx = zeros(size(x));
ny = zeros(size(y));
nz = zeros(size(z));
nx(ok) = x(ok) ./ r(ok);
ny(ok) = y(ok) ./ r(ok);
nz(ok) = z(ok) ./ r(ok);

s4pi = 1 / sqrt(4 * pi);
switch name
    case 's'
        Y = s4pi * ones(size(x));
    case 'pz'
        Y = sqrt(3 / (4 * pi)) * nz;
    case 'px'
        Y = sqrt(3 / (4 * pi)) * nx;
    case 'py'
        Y = sqrt(3 / (4 * pi)) * ny;
    case {'dz2', 'dz^2', 'd_z2'}
        Y = sqrt(5 / (16 * pi)) * (3 * nz.^2 - 1);
    case 'dxz'
        Y = sqrt(15 / (4 * pi)) * nx .* nz;
    case 'dyz'
        Y = sqrt(15 / (4 * pi)) * ny .* nz;
    case 'dxy'
        Y = sqrt(15 / (4 * pi)) * nx .* ny;
    case {'dx2-y2', 'dx2y2', 'd_x2-y2'}
        Y = sqrt(15 / (16 * pi)) * (nx.^2 - ny.^2);
    case {'fz3', 'fz^3'}
        Y = sqrt(7 / (16 * pi)) * (5 * nz.^3 - 3 * nz);
    case 'fxz2'
        Y = sqrt(21 / (32 * pi)) * nx .* (5 * nz.^2 - 1);
    case 'fyz2'
        Y = sqrt(21 / (32 * pi)) * ny .* (5 * nz.^2 - 1);
    case 'fxyz'
        Y = sqrt(105 / (4 * pi)) * nx .* ny .* nz;
    case {'fz(x2-y2)', 'fzx2y2'}
        Y = sqrt(105 / (16 * pi)) * nz .* (nx.^2 - ny.^2);
    case {'fx(x2-3y2)', 'fxx2y2'}
        Y = sqrt(35 / (32 * pi)) * nx .* (nx.^2 - 3 * ny.^2);
    case {'fy(3x2-y2)', 'fyx2y2'}
        Y = sqrt(35 / (32 * pi)) * ny .* (3 * nx.^2 - ny.^2);
    otherwise
        error('realY:name', 'Unknown angular name: %s', name);
end
end
