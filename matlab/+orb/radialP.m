function [P, r, rmp, rmean, normP] = radialP(n, l, zeff, rAng)
% RADIALP Radial probability density P(r) = r^2 R_nl(r)^2 (Beiser 6.7).
%
% [P, r, rmp, rmean, normP] = orb.radialP(n, l, zeff)
% [P, r, rmp, rmean, normP] = orb.radialP(n, l, zeff, rAng)
%
% rmp is the most probable r (max of P). rmean is <r> by trapezoidal
% quadrature. normP is integral P dr and should be ~1 on a long enough grid.

c = orb.physConst();
if nargin < 4 || isempty(rAng)
    rMax = 24 * (n^2) / max(zeff, 0.5) * c.a0_Ang;
    rAng = linspace(0, rMax, 5000);
end
r = rAng;
R = orb.radialR(n, l, zeff, r);
P = (r.^2) .* (R.^2);
normP = trapz(r, P);
if normP > 0
    rmean = trapz(r, r .* P) / normP;
else
    rmean = NaN;
end
[~, iMax] = max(P);
rmp = r(iMax);
end
