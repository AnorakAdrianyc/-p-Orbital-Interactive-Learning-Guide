function angularCloud(ax, name, nTheta, nPhi)
% ANGULARCLOUD Plot |Y|^2 as a radial balloon (angular probability).
%
% Unlit, opaque surf so the SVG path can stay a patch mesh.

if nargin < 3 || isempty(nTheta)
    nTheta = 48;
end
if nargin < 4 || isempty(nPhi)
    nPhi = 72;
end
th = linspace(0, pi, nTheta);
ph = linspace(0, 2 * pi, nPhi);
[TH, PH] = meshgrid(th, ph);
x = sin(TH) .* cos(PH);
y = sin(TH) .* sin(PH);
z = cos(TH);
Y = orb.realY(name, x, y, z);
A = Y.^2;
% Phase sign as a two-colour map (Beiser +/- lobes) but opaque.
sg = sign(Y);
sg(sg == 0) = 1;
C = 0.5 * (1 + sg);
X = A .* x;
Yy = A .* y;
Z = A .* z;
surf(ax, X, Yy, Z, C, 'EdgeColor', 'none', 'FaceColor', 'interp');
colormap(ax, [0.75 0.15 0.12; 0.12 0.35 0.75]);
caxis(ax, [0 1]);
axis(ax, 'equal');
axis(ax, 'off');
view(ax, 35, 22);
end
