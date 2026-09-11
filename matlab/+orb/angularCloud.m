function angularCloud(ax, name, nTheta, nPhi)
% ANGULARCLOUD 2-D polar plot of |Y|^2 in a principal plane (Beiser-style).
%
% Filled polar lobes export as small vector SVG. nTheta/nPhi kept so call
% sites need not change; the sample count is max(nTheta, 180).

if nargin < 3 || isempty(nTheta)
    nTheta = 180;
end
if nargin < 4 || isempty(nPhi)
    nPhi = nTheta;
end
n = max([nTheta, nPhi, 180]);
plane = principalPlane(name);
t = linspace(0, 2 * pi, n);
switch plane
    case 'xy'
        x = cos(t); y = sin(t); z = zeros(size(t));
        xlab = 'x'; ylab = 'y';
    case 'yz'
        x = zeros(size(t)); y = cos(t); z = sin(t);
        xlab = 'y'; ylab = 'z';
    otherwise
        x = cos(t); y = zeros(size(t)); z = sin(t);
        xlab = 'x'; ylab = 'z';
end
Y = orb.realY(name, x, y, z);
A = Y.^2;
peak = max(A);
if peak <= 0
    peak = 1;
end
A = A / peak;
switch plane
    case 'xy'
        u = A .* x; v = A .* y;
    case 'yz'
        u = A .* y; v = A .* z;
    otherwise
        u = A .* x; v = A .* z;
end
hold(ax, 'on');
% Colour by sign of Y (Beiser +/- lobe convention), opaque.
sg = [Y, Y(1)];
uu = [u, u(1)];
vv = [v, v(1)];
% Draw as many patches as sign runs.
i = 1;
N = numel(sg);
while i < N
    s0 = sign(sg(i));
    if s0 == 0
        i = i + 1;
        continue;
    end
    j = i;
    while j < N && sign(sg(j)) == s0
        j = j + 1;
    end
    col = [0.12 0.35 0.75];
    if s0 < 0
        col = [0.75 0.15 0.12];
    end
    pu = [0, uu(i:j), 0];
    pv = [0, vv(i:j), 0];
    patch(ax, pu, pv, col, 'EdgeColor', 'none');
    i = j;
end
plot(ax, uu, vv, 'k-', 'LineWidth', 0.8);
axis(ax, 'equal');
xlim(ax, [-1.2 1.2]); ylim(ax, [-1.2 1.2]);
xlabel(ax, xlab); ylabel(ax, ylab);
orb.styleAxes(ax);
end

function plane = principalPlane(name)
name = lower(name);
if any(strcmp(name, {'px', 'py', 'dxy', 'dx2-y2', 'fxyz', 'fx(x2-3y2)', 'fy(3x2-y2)'}))
    plane = 'xy';
elseif any(strcmp(name, {'dyz', 'fyz2'}))
    plane = 'yz';
else
    plane = 'xz';
end
end
