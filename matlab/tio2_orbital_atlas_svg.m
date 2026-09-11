function files = tio2_orbital_atlas_svg(outDir)
% TIO2_ORBITAL_ATLAS_SVG TiO2 panels: filling, 3d angular, TiO6 LFT vs d2sp3,
% oxygen sp2, radial along the bond, and 300 K bands.
%
% GEST3015 I-V. L2 lists d2sp3 for SF6-like octahedra; today's conclusion is
% that Ti(IV) oxides are described by ligand-field / MO theory, not a single
% hybridization label.

if nargin < 1 || isempty(outDir)
    outDir = orb.defaultExportDir();
end
if exist(outDir, 'dir') ~= 7
    mkdir(outDir);
end
orb.prepareGraphics();

files = {};
files{end+1} = panelFilling(outDir);
files{end+1} = panelAngular(outDir);
files{end+1} = panelOctahedron(outDir);
files{end+1} = panelOxygen(outDir);
files{end+1} = panelRadial(outDir);
files{end+1} = panelBands(outDir);
end

function f = panelFilling(outDir)
fig = figure('Color', 'w', 'Visible', 'off');
ax = axes('Parent', fig, 'Position', [0.10 0.08 0.82 0.84]);
cla(ax); hold(ax, 'on'); axis(ax, 'off'); set(ax, 'YDir', 'reverse');
text(ax, 0, 0.1, 'Ti atom  [Ar] 3d^2 4s^2', 'FontWeight', 'bold', 'FontSize', 11);
drawRow(ax, 0.7, '4s', [2]);
drawRow(ax, 2.0, '3d', [1 1 0 0 0]);
text(ax, 0, 3.6, 'Ti^{4+}  (d^0)  — empty 3d becomes the conduction band', ...
    'FontWeight', 'bold', 'FontSize', 11);
drawRow(ax, 4.2, '3d', [0 0 0 0 0]);
text(ax, 0, 5.7, 'O atom  2s^2 2p^4', 'FontWeight', 'bold', 'FontSize', 11);
drawRow(ax, 6.3, '2s', [2]);
drawRow(ax, 7.6, '2p', [2 1 1]);
text(ax, 0, 9.1, 'O^{2-}  2p^6  — filled 2p becomes the valence band', ...
    'FontWeight', 'bold', 'FontSize', 11);
drawRow(ax, 9.7, '2p', [2 2 2]);
axis(ax, [-2.5 8 -0.3 11.5]);
title(ax, 'TiO_2 formal filling: Ti^{4+} d^0 + O^{2-} p^6', 'FontSize', 12);
text(ax, -2.2, 11.2, 'Formal ionic count only. Covalency is in the O 2p / Ti 3d MO diagram.', ...
    'FontSize', 8);
f = fullfile(outDir, 'tio2_filling.svg');
orb.exportSvg(fig, f, 900, 720);
close(fig);
end

function drawRow(ax, y, lab, occ)
boxW = 0.75; boxH = 0.85; gap = 0.16;
text(ax, -0.15, y + boxH / 2, lab, 'HorizontalAlignment', 'right', ...
    'FontWeight', 'bold', 'FontSize', 10, 'Interpreter', 'none');
for j = 1:numel(occ)
    x = (j - 1) * (boxW + gap);
    rectangle(ax, 'Position', [x y boxW boxH], 'EdgeColor', [0.15 0.15 0.15], ...
        'LineWidth', 1.3, 'FaceColor', [1 1 1]);
    cx = x + boxW / 2;
    if occ(j) == 2
        text(ax, cx - 0.14, y + boxH * 0.52, '\uparrow', 'FontSize', 14, ...
            'HorizontalAlignment', 'center', 'Color', [0.10 0.25 0.55]);
        text(ax, cx + 0.14, y + boxH * 0.52, '\downarrow', 'FontSize', 14, ...
            'HorizontalAlignment', 'center', 'Color', [0.70 0.15 0.12]);
    elseif occ(j) == 1
        text(ax, cx, y + boxH * 0.52, '\uparrow', 'FontSize', 16, ...
            'HorizontalAlignment', 'center', 'Color', [0.10 0.25 0.55]);
    end
end
end

function f = panelAngular(outDir)
names = {'dz2', 'dx2-y2', 'dxy', 'dxz', 'dyz'};
tags  = {'e_g  d_{z^2}', 'e_g  d_{x^2-y^2}', 't_{2g}  d_{xy}', ...
         't_{2g}  d_{xz}', 't_{2g}  d_{yz}'};
fig = figure('Color', 'w', 'Visible', 'off');
for k = 1:5
    ax = axes('Parent', fig, 'Position', subplotPos(k, 5));
    hold(ax, 'on');
    orb.angularCloud(ax, names{k}, 36, 56);
    title(ax, tags{k}, 'FontSize', 9, 'Interpreter', 'tex');
end
% Top caption axes
axc = axes('Parent', fig, 'Position', [0.05 0.92 0.9 0.06]);
axis(axc, 'off');
text(axc, 0, 0.4, ['Ti 3d angular |Y|^2 in O_h: e_g points at ligands, t_{2g} between.  ', ...
    'Beiser 6.7 angular forms; GEST3015 II-III.'], 'FontSize', 10);
f = fullfile(outDir, 'tio2_3d_angular.svg');
orb.exportSvg(fig, f, 1100, 420);
close(fig);
end

function pos = subplotPos(k, n)
% One row of n axes.
w = 0.16; h = 0.72; gap = 0.025;
x = 0.04 + (k - 1) * (w + gap);
pos = [x 0.10 w h];
end

function f = panelOctahedron(outDir)
fig = figure('Color', 'w', 'Visible', 'off');
ax = axes('Parent', fig, 'Position', [0.05 0.08 0.55 0.84]);
hold(ax, 'on'); axis(ax, 'equal'); view(ax, 38, 22); grid(ax, 'on');
[xs, ys, zs] = sphere(16);
bondEq = 1.95; bondAp = 1.98;
dirs = [1 0 0; -1 0 0; 0 1 0; 0 -1 0; 0 0 1; 0 0 -1];
len = [bondEq; bondEq; bondEq; bondEq; bondAp; bondAp];
surf(ax, 0.28 * xs, 0.28 * ys, 0.28 * zs, 'FaceColor', [0.45 0.45 0.50], 'EdgeColor', 'none');
text(ax, 0, 0, 0.45, 'Ti', 'Color', 'w', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
for k = 1:6
    p = len(k) * dirs(k, :);
    plot3(ax, [0 p(1)], [0 p(2)], [0 p(3)], 'k-', 'LineWidth', 1.4);
    surf(ax, 0.22 * xs + p(1), 0.22 * ys + p(2), 0.22 * zs + p(3), ...
        'FaceColor', [0.80 0.20 0.15], 'EdgeColor', 'none');
    text(ax, p(1)*1.15, p(2)*1.15, p(3)*1.15, 'O', 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');
end
% eg lobe markers along axes (larger, pale)
for k = 1:6
    q = 0.85 * dirs(k, :);
    surf(ax, 0.32 * xs + q(1), 0.32 * ys + q(2), 0.32 * zs + q(3), ...
        'FaceColor', [0.95 0.75 0.25], 'EdgeColor', [0.6 0.4 0.1]);
end
xlabel(ax, 'x (A)'); ylabel(ax, 'y (A)'); zlabel(ax, 'z (A)');
title(ax, 'Idealised TiO_6 (rutile-like)');
xlim(ax, [-2.6 2.6]); ylim(ax, [-2.6 2.6]); zlim(ax, [-2.6 2.6]);

ax2 = axes('Parent', fig, 'Position', [0.62 0.12 0.34 0.78]);
axis(ax2, 'off'); hold(ax2, 'on');
text(ax2, 0, 1.00, 'L2 candidate: d^2sp^3 (SF_6 slide)', 'FontWeight', 'bold', 'FontSize', 10);
text(ax2, 0, 0.90, {'VB hybridization label for CN = 6.', ...
    'Useful as a geometry mnemonic only.'}, 'FontSize', 8);
text(ax2, 0, 0.72, 'Used here: ligand-field / MO', 'FontWeight', 'bold', 'FontSize', 10, ...
    'Color', [0.10 0.40 0.20]);
text(ax2, 0, 0.58, {'e_g (d_{z^2}, d_{x^2-y^2}) point at O and are', ...
    'pushed up; t_{2g} sit between ligands.', ...
    '', ...
    '\Delta_o splitting (schematic, not to scale):'}, 'FontSize', 8);
% Delta_o inset
rectangle(ax2, 'Position', [0.05 0.18 0.55 0.08], 'FaceColor', [0.20 0.45 0.80], 'EdgeColor', 'k');
rectangle(ax2, 'Position', [0.05 0.34 0.55 0.08], 'FaceColor', [0.85 0.55 0.12], 'EdgeColor', 'k');
text(ax2, 0.63, 0.22, 't_{2g}', 'FontSize', 9);
text(ax2, 0.63, 0.38, 'e_g', 'FontSize', 9);
plot(ax2, [0.64 0.64], [0.26 0.34], 'k-', 'LineWidth', 1.5);
text(ax2, 0.67, 0.30, '\Delta_o', 'FontSize', 10);
text(ax2, 0, 0.08, {'Rutile Ti-O \approx 1.95 / 1.98 A (distortion', ...
    'noted, not modelled). GEST3015 II.'}, 'FontSize', 8);
xlim(ax2, [0 1]); ylim(ax2, [0 1.05]);
f = fullfile(outDir, 'tio2_octahedron_lft.svg');
orb.exportSvg(fig, f, 1000, 700);
close(fig);
end

function f = panelOxygen(outDir)
Z2s = orb.zeff('O', 2, 0);
Z2p = orb.zeff('O', 2, 1);
nG = 101;
u = linspace(-2.4, 2.4, nG);
v = linspace(-2.4, 2.4, nG);
[U, V] = meshgrid(u, v);
X = U; Y = V; Z = zeros(size(U));
r = sqrt(X.^2 + Y.^2 + Z.^2);
Rs = orb.radialR(2, 0, Z2s, r);
Rp = orb.radialR(2, 1, Z2p, r);
psi = orb.hybrid('sp2', X, Y, Z, Rs, Rp);
dens = psi{1}.^2 + psi{2}.^2 + psi{3}.^2;
fig = figure('Color', 'w', 'Visible', 'off');
ax = axes('Parent', fig, 'Position', [0.08 0.12 0.54 0.78]);
hold(ax, 'on');
colormap(ax, orb.cloudColormap(256));
contourf(ax, U, V, dens, 16, 'LineStyle', 'none');
% three 120 deg bonds in plane
for a = [0, 120, 240]
    ang = a * pi / 180;
    plot(ax, [0 1.7 * cos(ang)], [0 1.7 * sin(ang)], 'k-', 'LineWidth', 1.2);
    plot(ax, 1.7 * cos(ang), 1.7 * sin(ang), 'o', 'MarkerFaceColor', [0.4 0.4 0.45], ...
        'MarkerSize', 8);
    text(ax, 1.85 * cos(ang), 1.85 * sin(ang), 'Ti', 'FontWeight', 'bold');
end
plot(ax, 0, 0, 'o', 'MarkerFaceColor', [0.80 0.18 0.12], 'MarkerSize', 9);
text(ax, 0.12, 0.12, 'O', 'Color', [0.80 0.18 0.12], 'FontWeight', 'bold');
axis(ax, 'equal'); xlim(ax, [-2.4 2.4]); ylim(ax, [-2.4 2.4]);
xlabel(ax, 'x (A)'); ylabel(ax, 'y (A)');
title(ax, 'O sp^2 \sigma framework in the OTi_3 plane');
orb.styleAxes(ax);

ax2 = axes('Parent', fig, 'Position', [0.66 0.15 0.30 0.70]);
axis(ax2, 'off');
text(ax2, 0, 0.95, 'sp^2 + p_\perp', 'FontWeight', 'bold', 'FontSize', 12);
text(ax2, 0, 0.78, {'Each hybrid is 1/3 s + 2/3 p', ...
    '(Beiser 8.5, L2 ethene/benzene).', '', ...
    'The leftover 2p_z is perpendicular', ...
    'to the plane and \pi-donates into', ...
    'Ti t_{2g} — this is the O 2p', ...
    'valence-band character.', '', ...
    'Ideal trigonal plane; rutile O is', ...
    'slightly puckered (not modelled).'}, 'FontSize', 9);
xlim(ax2, [0 1]); ylim(ax2, [0 1]);
f = fullfile(outDir, 'tio2_oxygen_sp2.svg');
orb.exportSvg(fig, f, 1000, 700);
close(fig);
end

function f = panelRadial(outDir)
Zti = orb.zeff('Ti', 3, 2);
Zo  = orb.zeff('O', 2, 1);
bond = 1.95;
[Pti, r] = orb.radialP(3, 2, Zti);
Po = orb.radialP(2, 1, Zo, r);
fig = figure('Color', 'w', 'Visible', 'off');
ax = axes('Parent', fig); hold(ax, 'on');
plot(ax, r, Pti, 'Color', [0.40 0.40 0.45], 'LineWidth', 1.8);
plot(ax, r, Po,  'Color', [0.80 0.20 0.15], 'LineWidth', 1.8);
yl = ylim(ax);
plot(ax, [bond bond], yl, 'k--', 'LineWidth', 1.1);
text(ax, bond + 0.05, yl(2) * 0.9, 'Ti-O 1.95 A', 'FontSize', 8);
xlim(ax, [0 3.2]);
xlabel(ax, 'r (Angstrom) from each nucleus');
ylabel(ax, 'P(r)');
legend(ax, {'Ti 3d, Z_{eff}=8.141', 'O 2p, Z_{eff}=4.453', 'bond length'}, ...
    'Location', 'northeast');
title(ax, 'Radial clouds along a Ti-O bond (hydrogenic Z_{eff})');
orb.styleAxes(ax);
text(ax, 0.02, -0.16, 'Slater: Ti 3d 3.65, O 2p 4.55. Clementi-Raimondi 3d is much tighter (inner 3d).', ...
    'Units', 'normalized', 'FontSize', 8);
f = fullfile(outDir, 'tio2_radial_bond.svg');
orb.exportSvg(fig, f, 900, 620);
close(fig);
end

function f = panelBands(outDir)
c = orb.physConst();
EgR = 3.00; EgA = 3.20;
lamR = c.hc_eVnm / EgR;
lamA = c.hc_eVnm / EgA;
fig = figure('Color', 'w', 'Visible', 'off');
ax = axes('Parent', fig); hold(ax, 'on'); axis(ax, 'off');
% VB
rectangle(ax, 'Position', [1.0 0.8 3.2 1.4], 'FaceColor', [0.80 0.25 0.15], 'EdgeColor', 'k');
text(ax, 2.6, 1.5, 'O 2p  valence band', 'Color', 'w', 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center');
% CB
rectangle(ax, 'Position', [1.0 0.8+1.4+EgR, 3.2, 1.4], 'FaceColor', [0.40 0.40 0.48], 'EdgeColor', 'k');
text(ax, 2.6, 0.8+1.4+EgR+0.7, 'Ti 3d t_{2g}  conduction band', 'Color', 'w', ...
    'FontWeight', 'bold', 'HorizontalAlignment', 'center');
% gaps
plot(ax, [4.4 4.4], [0.8+1.4, 0.8+1.4+EgR], 'k-', 'LineWidth', 2);
text(ax, 4.55, 0.8+1.4+EgR/2, sprintf('E_g(rutile) = %.1f eV\n~ %.0f nm', EgR, lamR), 'FontSize', 9);
plot(ax, [5.7 5.7], [0.8+1.4, 0.8+1.4+EgA], 'Color', [0.3 0.3 0.3], 'LineWidth', 1.5);
text(ax, 5.85, 0.8+1.4+EgA/2, sprintf('E_g(anatase) = %.1f eV\n~ %.0f nm', EgA, lamA), 'FontSize', 9);
% oxygen vacancy donor
plot(ax, 3.6, 0.8+1.4+0.35, 'v', 'MarkerSize', 10, 'MarkerFaceColor', [0.9 0.8 0.2]);
text(ax, 3.75, 0.8+1.4+0.55, 'V_O donor (schematic)', 'FontSize', 8);
orb.ktBar(ax, 0.55, 0.8+1.4, 0.8+1.4 + 12 * c.kT_eV, 'kT (300 K)');
text(ax, 0.15, 0.8+1.4 + 12 * c.kT_eV + 0.2, 'bar x12', 'FontSize', 7, 'Color', [0.80 0.25 0.10]);
xlim(ax, [0 8.4]); ylim(ax, [0 7.2]);
title(ax, 'TiO_2: O 2p \rightarrow Ti 3d gap at 300 K (UV absorption)', 'FontSize', 12);
text(ax, 1.0, 0.35, sprintf('E_g / kT \\approx %.0f (rutile). Optical onset is UV; kT does not populate the CB thermally.', EgR / c.kT_eV), ...
    'FontSize', 8);
text(ax, 1.0, 0.12, 'Beiser 9.10, 10.6-10.7; GEST3015 III-V (photocatalyst / solar).', 'FontSize', 8);
f = fullfile(outDir, 'tio2_bands_300K.svg');
orb.exportSvg(fig, f, 1000, 700);
close(fig);
end
