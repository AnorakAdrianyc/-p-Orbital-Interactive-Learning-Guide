function cmap = cloudColormap(n)
% CLOUDCOLORMAP Opaque sequential colormap for |psi|^2 (no parula).
%
% White -> gold -> teal -> navy. Fully opaque so SVG export stays vector.

if nargin < 1 || isempty(n)
    n = 256;
end
stops = [ ...
    1.00 1.00 1.00; ...
    1.00 0.92 0.70; ...
    0.20 0.65 0.70; ...
    0.05 0.18 0.42];
t = linspace(0, 1, n)';
xs = linspace(0, 1, size(stops, 1));
cmap = [interp1(xs, stops(:, 1), t), ...
        interp1(xs, stops(:, 2), t), ...
        interp1(xs, stops(:, 3), t)];
cmap = min(max(cmap, 0), 1);
end
