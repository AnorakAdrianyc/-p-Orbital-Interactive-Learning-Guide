function ktBar(ax, x, y0, y1, label)
% KTBAR Draw a kT(300 K) reference bar on an energy axis.
%
% orb.ktBar(ax, x, y0, y1, label)
%   vertical bar at abscissa x from y0 to y1 (data units).
%   label defaults to 'kT (300 K)'.

if nargin < 1 || isempty(ax)
    ax = gca;
end
if nargin < 5 || isempty(label)
    label = 'kT (300 K)';
end
c = orb.physConst();
hold(ax, 'on');
plot(ax, [x x], [y0 y1], 'Color', [0.80 0.25 0.10], 'LineWidth', 3);
text(ax, x, y1, sprintf('  %s\n  %.1f meV\n  %.0f cm^{-1}', ...
    label, c.kT_meV, c.kT_cm), ...
    'FontSize', 8, 'Color', [0.80 0.25 0.10], 'VerticalAlignment', 'bottom');
end
