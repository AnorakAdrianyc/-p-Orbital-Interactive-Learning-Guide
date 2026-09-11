function files = si_orbital_atlas_svg(outDir)
% SI_ORBITAL_ATLAS_SVG Silicon panels: filling, P(r), sp3 cloud, tetrahedron, bands.
%
% GEST3015 I-IV / Beiser 6.7, 8.5, 10.3, 10.6-10.7. Room temperature = 300 K
% enters through Eg = 1.12 eV, n_i, lattice constant and the kT bar — not
% through orbital shape.

if nargin < 1 || isempty(outDir)
    outDir = orb.defaultExportDir();
end
if exist(outDir, 'dir') ~= 7
    mkdir(outDir);
end
orb.prepareGraphics();

files = {};
files{end+1} = panelFilling(outDir);
files{end+1} = panelRadial(outDir);
files{end+1} = panelCrossSection(outDir);
files{end+1} = panelTetrahedron(outDir);
files{end+1} = panelBands(outDir);
end

function f = panelFilling(outDir)
fig = figure('Color', 'w', 'Visible', 'off', 'Name', 'si_filling');
ax = axes('Parent', fig, 'Position', [0.08 0.10 0.84 0.80]);
% Three stages stacked as separate mini-diagrams.
cla(ax); hold(ax, 'on'); axis(ax, 'off');
set(ax, 'YDir', 'reverse');
drawStage(ax, 0.2, 'ground [Ne] 3s^2 3p^2', {'3s', [2]; '3p', [1 1 0]});
drawStage(ax, 4.0, 'promoted 3s^1 3p^3', {'3s', [1]; '3p', [1 1 1]});
drawStage(ax, 7.8, 'four equivalent sp^3 (diamond cubic)', ...
    {'sp3', [1 1 1 1]});
axis(ax, [-2.5 8 -0.5 12]);
title(ax, 'Si valence filling \rightarrow sp^3 (Beiser 8.5, L2)', 'FontSize', 12);
text(ax, 0, 11.4, {'Hund: two unpaired 3p electrons in the atom.'; ...
    'In the crystal the four sp^3 hybrids each hold one electron and form', ...
    'four equivalent Si-Si sigma bonds (GEST3015 I-II).'}, ...
    'FontSize', 8, 'VerticalAlignment', 'top');
f = fullfile(outDir, 'si_filling.svg');
orb.exportSvg(fig, f, 900, 700);
close(fig);
end

function drawStage(ax, y, heading, rows)
text(ax, 0, y, heading, 'FontSize', 10, 'FontWeight', 'bold', 'Interpreter', 'none');
boxW = 0.75; boxH = 0.85; gap = 0.16;
for i = 1:size(rows, 1)
    lab = rows{i, 1};
    occ = rows{i, 2};
    yy = y + 0.55 + (i - 1) * 1.25;
    text(ax, -0.1, yy + boxH / 2, lab, 'HorizontalAlignment', 'right', ...
        'FontSize', 10, 'FontWeight', 'bold', 'Interpreter', 'none');
    for j = 1:numel(occ)
        x = (j - 1) * (boxW + gap);
        rectangle(ax, 'Position', [x yy boxW boxH], ...
            'EdgeColor', [0.15 0.15 0.15], 'LineWidth', 1.3, 'FaceColor', [1 1 1]);
        occj = occ(j);
        cx = x + boxW / 2;
        if occj == 2
            text(ax, cx - 0.14, yy + boxH * 0.52, '\uparrow', ...
                'FontSize', 14, 'HorizontalAlignment', 'center', 'Color', [0.10 0.25 0.55]);
            text(ax, cx + 0.14, yy + boxH * 0.52, '\downarrow', ...
                'FontSize', 14, 'HorizontalAlignment', 'center', 'Color', [0.70 0.15 0.12]);
        elseif occj == 1
            text(ax, cx, yy + boxH * 0.52, '\uparrow', ...
                'FontSize', 16, 'HorizontalAlignment', 'center', 'Color', [0.10 0.25 0.55]);
        end
    end
end
end

function f = panelRadial(outDir)
Z3s = orb.zeff('Si', 3, 0);
Z3p = orb.zeff('Si', 3, 1);
[P3s, r] = orb.radialP(3, 0, Z3s);
P3p = orb.radialP(3, 1, Z3p, r);
halfBond = 1.176;  % sqrt(3)*5.431/8 Angstrom
fig = figure('Color', 'w', 'Visible', 'off');
ax = axes('Parent', fig); hold(ax, 'on');
plot(ax, r, P3s, 'Color', [0.10 0.45 0.75], 'LineWidth', 1.8);
plot(ax, r, P3p, 'Color', [0.80 0.35 0.10], 'LineWidth', 1.8);
yl = ylim(ax);
plot(ax, [halfBond halfBond], yl, '--', 'Color', [0.2 0.2 0.2], 'LineWidth', 1.1);
text(ax, halfBond + 0.05, yl(2) * 0.92, 'half-bond 1.176 A', 'FontSize', 8);
xlim(ax, [0 4]);
xlabel(ax, 'r (Angstrom)');
ylabel(ax, 'P(r) = r^2 R(r)^2');
legend(ax, {'Si 3s, Z_{eff}=4.903', 'Si 3p, Z_{eff}=4.285', 'Si-Si/2'}, ...
    'Location', 'northeast');
title(ax, 'Si radial probability (hydrogenic Z_{eff}; Beiser 6.7)');
orb.styleAxes(ax);
text(ax, 0.05, -0.18, 'Slater 3p Z_{eff}=4.15 (footnote). Not a DFT orbital.', ...
    'Units', 'normalized', 'FontSize', 8, 'Color', [0.3 0.3 0.3]);
f = fullfile(outDir, 'si_radial_P.svg');
orb.exportSvg(fig, f, 900, 620);
close(fig);
end

function f = panelCrossSection(outDir)
% y = z plane contains two tetrahedral bonds (angle 109.47 deg).
Z3s = orb.zeff('Si', 3, 0);
Z3p = orb.zeff('Si', 3, 1);
bond = 2.352;
nG = 121;
u = linspace(-3.2, 3.2, nG);
v = linspace(-3.2, 3.2, nG);
[U, V] = meshgrid(u, v);
% Plane y = z: x = U, y = V/sqrt(2), z = V/sqrt(2)
X = U;
Y = V / sqrt(2);
Z = V / sqrt(2);
r = sqrt(X.^2 + Y.^2 + Z.^2);
Rs = orb.radialR(3, 0, Z3s, r);
Rp = orb.radialR(3, 1, Z3p, r);
psi = orb.hybrid('sp3', X, Y, Z, Rs, Rp);
dens = psi{1}.^2 + psi{2}.^2;
fig = figure('Color', 'w', 'Visible', 'off');
ax = axes('Parent', fig); hold(ax, 'on');
colormap(ax, orb.cloudColormap(256));
contourf(ax, U, V, dens, 18, 'LineStyle', 'none');
% Neighbour projections: d1=[1,1,1], d2=[1,-1,-1] already in the plane.
d = orb.tetraDirs();
% Project onto (x, (y+z)/sqrt(2))
for k = 1:2
    px = d(k, 1) * bond;
    pv = (d(k, 2) + d(k, 3)) / sqrt(2) * bond;
    plot(ax, [0 px], [0 pv], 'k-', 'LineWidth', 1.2);
    plot(ax, px, pv, 'o', 'MarkerFaceColor', [0.2 0.2 0.2], ...
        'MarkerEdgeColor', 'k', 'MarkerSize', 8);
    text(ax, px * 1.05, pv * 1.05, 'Si', 'FontSize', 9, 'FontWeight', 'bold');
end
plot(ax, 0, 0, 'o', 'MarkerFaceColor', [0.75 0.15 0.12], ...
    'MarkerEdgeColor', 'k', 'MarkerSize', 9);
text(ax, 0.12, 0.12, 'Si', 'Color', [0.75 0.15 0.12], 'FontWeight', 'bold');
axis(ax, 'equal');
xlim(ax, [-3.2 3.2]); ylim(ax, [-3.2 3.2]);
xlabel(ax, 'x (A)');
ylabel(ax, '(y+z)/sqrt(2)  [plane y = z]');
title(ax, sprintf('|\\psi_{sp^3}|^2, two lobes, angle arccos(-1/3) = 109.47^\\circ'));
orb.styleAxes(ax);
cb = colorbar(ax);
set(get(cb, 'Title'), 'String', '|\\psi|^2');
f = fullfile(outDir, 'si_sp3_cross_section.svg');
orb.exportSvg(fig, f, 900, 720);
close(fig);
end

function f = panelTetrahedron(outDir)
d = orb.tetraDirs();
bond = 2.352;
fig = figure('Color', 'w', 'Visible', 'off');
ax = axes('Parent', fig); hold(ax, 'on');
axis(ax, 'equal');
view(ax, 35, 22);
grid(ax, 'on');
[xs, ys, zs] = sphere(18);
% Central nucleus
surf(ax, 0.28 * xs, 0.28 * ys, 0.28 * zs, ...
    'FaceColor', [0.75 0.15 0.12], 'EdgeColor', 'none');
cols = [0.15 0.45 0.80; 0.20 0.65 0.55; 0.85 0.55 0.12; 0.55 0.30 0.70];
for k = 1:4
    p = bond * d(k, :);
    plot3(ax, [0 p(1)], [0 p(2)], [0 p(3)], 'k-', 'LineWidth', 1.5);
    % Hybrid lobe as an ellipsoid along the bond (pedagogical isosurface proxy)
    lobeR = 0.55;
    cx = 0.55 * p(1); cy = 0.55 * p(2); cz = 0.55 * p(3);
    surf(ax, lobeR * xs + cx, lobeR * ys + cy, lobeR * zs + cz, ...
        'FaceColor', cols(k, :), 'EdgeColor', 'none');
    surf(ax, 0.22 * xs + p(1), 0.22 * ys + p(2), 0.22 * zs + p(3), ...
        'FaceColor', [0.25 0.25 0.25], 'EdgeColor', 'none');
end
% Unit-cell hint: cube outline scaled to a/4 tetrahedron
xlabel(ax, 'x (A)'); ylabel(ax, 'y (A)'); zlabel(ax, 'z (A)');
title(ax, 'Si diamond-cubic: four sp^3 hybrids (ideal tetrahedron)');
text(ax, -2.8, -2.8, 2.6, ...
    {'a = 5.431 A (300 K); nn = \sqrt3 a/4 = 2.352 A'; ...
     'Unlit patches: not a DFT isosurface. GEST3015 I-II / Beiser 10.3'}, ...
    'FontSize', 8, 'BackgroundColor', 'w');
xlim(ax, [-3 3]); ylim(ax, [-3 3]); zlim(ax, [-3 3]);
f = fullfile(outDir, 'si_sp3_tetrahedron.svg');
orb.exportSvg(fig, f, 900, 720);
close(fig);
end

function f = panelBands(outDir)
c = orb.physConst();
Eg = 1.12;
fig = figure('Color', 'w', 'Visible', 'off');
ax = axes('Parent', fig); hold(ax, 'on');
axis(ax, 'off');
% Column x positions
xA = 0.4; xH = 2.2; xB = 4.0; xG = 6.2;
drawLevel(ax, xA, 1.6, 1.0, 0.35, [0.20 0.50 0.80], '3s');
drawLevel(ax, xA, 3.1, 1.0, 0.55, [0.80 0.40 0.15], '3p');
drawLevel(ax, xH, 2.4, 1.0, 0.70, [0.45 0.35 0.70], 'sp^3');
% VB / CB
drawLevel(ax, xB, 1.3, 1.3, 1.10, [0.15 0.45 0.75], 'bonding / VB');
drawLevel(ax, xB, 1.3 + 1.10 + Eg, 1.3, 1.10, [0.80 0.35 0.12], 'antibonding / CB');
% arrows
plot(ax, [xA+1.05, xH], [2.5, 2.7], 'k-');
plot(ax, [xH+1.05, xB], [2.7, 2.4], 'k-');
text(ax, xG, 1.8, sprintf('E_g = %.2f eV (300 K)', Eg), 'FontSize', 11, 'FontWeight', 'bold');
text(ax, xG, 1.35, sprintf('kT = %.1f meV    E_g / kT \\approx %.0f', c.kT_meV, Eg / c.kT_eV), ...
    'FontSize', 10);
text(ax, xG, 0.90, 'n_i \\approx 1\\times10^{10} cm^{-3} (300 K)', 'FontSize', 10);
text(ax, xG, 0.45, {'Indirect gap: VBM at \\Gamma, CBM near X'; ...
    '(phonon required). Beiser 10.6-10.7.'}, 'FontSize', 9);
% kT bar next to the gap
gapBottom = 1.3 + 1.10;
gapTop = gapBottom + Eg;
orb.ktBar(ax, xB + 1.55, gapBottom, gapBottom + c.kT_eV * 8, 'kT (300 K)');
% scale note: kT bar is magnified 8x so it is visible next to Eg
text(ax, xB + 1.65, gapBottom + c.kT_eV * 8 + 0.15, 'bar \\times8 for visibility', ...
    'FontSize', 7, 'Color', [0.80 0.25 0.10]);
plot(ax, [xB + 0.1, xB + 1.2], [gapBottom, gapBottom], 'k--');
plot(ax, [xB + 0.1, xB + 1.2], [gapTop, gapTop], 'k--');
text(ax, xB + 1.35, (gapBottom + gapTop) / 2, 'E_g', 'FontSize', 10);
xlim(ax, [0 10]); ylim(ax, [0 5.2]);
title(ax, 'Si: atomic \rightarrow hybrid \rightarrow bands at 300 K', 'FontSize', 12);
text(ax, 0.4, 0.15, 'Orbital shape is T-independent; occupation (Fermi-Dirac) is not.', ...
    'FontSize', 8, 'Color', [0.3 0.3 0.3]);
f = fullfile(outDir, 'si_bands_300K.svg');
orb.exportSvg(fig, f, 1000, 700);
close(fig);
end

function drawLevel(ax, x, y, w, h, col, lab)
rectangle(ax, 'Position', [x y w h], 'FaceColor', col, 'EdgeColor', [0.15 0.15 0.15], ...
    'LineWidth', 1.0);
text(ax, x + w / 2, y + h / 2, lab, 'Color', 'w', 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'FontSize', 9, 'Interpreter', 'none');
end
