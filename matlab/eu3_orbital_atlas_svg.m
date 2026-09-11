function files = eu3_orbital_atlas_svg(outDir)
% EU3_ORBITAL_ATLAS_SVG Eu3+ panels: 4f6 Hund, 4f angular set, shielding,
% CN 8/9 polyhedra, and 7F_J / 5D0 ladder at 300 K.
%
% No hybridization label: 4f is buried inside 5s/5p, ligand field is weak,
% bonding is essentially ionic. GEST3015 II / Beiser 7.4-7.8, 9.2.

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
files{end+1} = panelShielding(outDir);
files{end+1} = panelPolyhedra(outDir);
files{end+1} = panelLadder(outDir);
end

function f = panelFilling(outDir)
fig = figure('Color', 'w', 'Visible', 'off');
ax = axes('Parent', fig); hold(ax, 'on'); axis(ax, 'off'); set(ax, 'YDir', 'reverse');
text(ax, 0, 0.15, 'Eu^{3+}  [Xe] 4f^6   (not the neutral Eu 4f^7 6s^2 atom)', ...
    'FontWeight', 'bold', 'FontSize', 12);
% 7 f-orbitals, 6 unpaired
boxW = 0.72; boxH = 0.90; gap = 0.14; y = 1.0;
text(ax, -0.2, y + boxH / 2, '4f', 'FontWeight', 'bold', 'FontSize', 12, ...
    'HorizontalAlignment', 'right');
occ = [1 1 1 1 1 1 0];
for j = 1:7
    x = (j - 1) * (boxW + gap);
    rectangle(ax, 'Position', [x y boxW boxH], 'EdgeColor', [0.15 0.15 0.15], ...
        'LineWidth', 1.4, 'FaceColor', [1 1 1]);
    if occ(j) == 1
        text(ax, x + boxW / 2, y + boxH * 0.52, '\uparrow', 'FontSize', 18, ...
            'HorizontalAlignment', 'center', 'Color', [0.10 0.25 0.55]);
    end
end
text(ax, 0, 2.4, {'Hund (Beiser 7.6): maximize S, then L.', ...
    '  S = 6 \times 1/2 = 3    \rightarrow  2S+1 = 7', ...
    '  L = 3  (term letter F)', ...
    '  4f^6 is less than half filled \rightarrow  J = |L - S| = 0', ...
    '  Ground level: ^{7}F_{0}   (Beiser 7.8 term symbol).'}, 'FontSize', 11);
text(ax, 0, 5.0, {'Closed 5s^{2} 5p^{6} shells of the Xe core remain. They shield 4f', ...
    'from the ligands — see the radial panel. Do not assign sp^{3}d^{n} hybrids.'}, ...
    'FontSize', 10);
axis(ax, [-2 8 -0.2 6.2]);
title(ax, 'Eu^{3+} 4f^6 high-spin filling \rightarrow ^{7}F_{0}', 'FontSize', 13);
f = fullfile(outDir, 'eu3_filling.svg');
orb.exportSvg(fig, f, 900, 620);
close(fig);
end

function f = panelAngular(outDir)
names = orb.angularNames(3);
fig = figure('Color', 'w', 'Visible', 'off');
for k = 1:7
    row = floor((k - 1) / 4);
    col = mod(k - 1, 4);
    ax = axes('Parent', fig, 'Position', [0.06 + col * 0.24, 0.50 - row * 0.42, 0.20, 0.36]);
    hold(ax, 'on');
    orb.angularCloud(ax, names{k}, 32, 48);
    title(ax, names{k}, 'FontSize', 8, 'Interpreter', 'none');
end
axc = axes('Parent', fig, 'Position', [0.06 0.92 0.88 0.06]);
axis(axc, 'off');
text(axc, 0, 0.3, 'Real 4f angular |Y_{l=3}|^2 (seven orbitals). Extension of Beiser Table 6.1 / 6.7 to l = 3.', ...
    'FontSize', 10);
f = fullfile(outDir, 'eu3_4f_angular.svg');
orb.exportSvg(fig, f, 1100, 720);
close(fig);
end

function f = panelShielding(outDir)
Zf = orb.zeff('Eu', 4, 3);
Zs = orb.zeff('Eu', 5, 0);
Zp = orb.zeff('Eu', 5, 1);
[Pf, r] = orb.radialP(4, 3, Zf);
Ps = orb.radialP(5, 0, Zs, r);
Pp = orb.radialP(5, 1, Zp, r);
rIon = 1.066;  % Shannon Eu3+ CN 8
rEO  = 2.40;
fig = figure('Color', 'w', 'Visible', 'off');
ax = axes('Parent', fig); hold(ax, 'on');
plot(ax, r, Pf, 'Color', [0.55 0.20 0.65], 'LineWidth', 1.9);
plot(ax, r, Ps, 'Color', [0.15 0.50 0.75], 'LineWidth', 1.6);
plot(ax, r, Pp, 'Color', [0.15 0.65 0.40], 'LineWidth', 1.6);
yl = ylim(ax);
plot(ax, [rIon rIon], yl, '--', 'Color', [0.2 0.2 0.2]);
plot(ax, [rEO rEO], yl, ':', 'Color', [0.2 0.2 0.2], 'LineWidth', 1.2);
text(ax, rIon + 0.03, yl(2) * 0.92, 'Shannon r(Eu^{3+}, CN8) 1.066 A', 'FontSize', 8);
text(ax, rEO + 0.03, yl(2) * 0.80, 'typical Eu-O \approx 2.4 A', 'FontSize', 8);
xlim(ax, [0 3.2]);
xlabel(ax, 'r (Angstrom)');
ylabel(ax, 'P(r)');
legend(ax, {'4f  Z_{eff}=24.32', '5s  Z_{eff}=18.59', '5p  Z_{eff}=16.56'}, ...
    'Location', 'northeast');
title(ax, 'Eu^{3+}: 4f is inside 5s/5p — buried, weak ligand field');
orb.styleAxes(ax);
text(ax, 0.02, -0.18, ...
    '4f does not hybridize with ligand orbitals at the Beiser/L2 level. Ionic bonding + weak CF splitting.', ...
    'Units', 'normalized', 'FontSize', 8);
f = fullfile(outDir, 'eu3_radial_shielding.svg');
orb.exportSvg(fig, f, 900, 620);
close(fig);
end

function f = panelPolyhedra(outDir)
[d8, lab8] = idgeometryexplorer.geometry('squareantiprismatic');
[d9, lab9] = idgeometryexplorer.geometry('tricappedtrigonalprismatic');
fig = figure('Color', 'w', 'Visible', 'off');
ax1 = axes('Parent', fig, 'Position', [0.06 0.10 0.42 0.78]);
drawComplex(ax1, d8, 'Eu', 'O', lab8);
ax2 = axes('Parent', fig, 'Position', [0.54 0.10 0.42 0.78]);
drawComplex(ax2, d9, 'Eu', 'O', lab9);
axc = axes('Parent', fig, 'Position', [0.06 0.92 0.88 0.06]);
axis(axc, 'off');
text(axc, 0, 0.3, 'Idealised Eu^{3+} coordination (idgeometryexplorer). Ligand-dependent; not a hybridization assignment.', ...
    'FontSize', 10);
f = fullfile(outDir, 'eu3_polyhedra.svg');
orb.exportSvg(fig, f, 1100, 700);
close(fig);
end

function drawComplex(ax, dirs, metal, ligand, label)
hold(ax, 'on'); axis(ax, 'equal'); view(ax, 35, 22); grid(ax, 'on');
[xs, ys, zs] = sphere(14);
surf(ax, 0.32 * xs, 0.32 * ys, 0.32 * zs, 'FaceColor', [0.55 0.20 0.65], 'EdgeColor', 'none');
text(ax, 0, 0, 0, metal, 'Color', 'w', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
scale = 2.05;
for k = 1:size(dirs, 1)
    p = scale * dirs(k, :);
    plot3(ax, [0 p(1)], [0 p(2)], [0 p(3)], 'k-', 'LineWidth', 1.3);
    surf(ax, 0.20 * xs + p(1), 0.20 * ys + p(2), 0.20 * zs + p(3), ...
        'FaceColor', [0.80 0.20 0.15], 'EdgeColor', 'none');
    text(ax, p(1), p(2), p(3) + 0.28, ligand, 'FontSize', 8, ...
        'HorizontalAlignment', 'center');
end
title(ax, label, 'FontSize', 10);
xlabel(ax, 'x'); ylabel(ax, 'y'); zlabel(ax, 'z');
xlim(ax, [-3 3]); ylim(ax, [-3 3]); zlim(ax, [-3 3]);
end

function f = panelLadder(outDir)
% Binnemans, Coord. Chem. Rev. 295, 1 (2015) free-ion barycenters.
EJ = [0, 379, 1043, 1896, 2869, 3912, 4992];
gJ = 2 * (0:6) + 1;
E5D0 = 17227;
pop = orb.boltzmann(EJ, gJ, 300);
c = orb.physConst();
fig = figure('Color', 'w', 'Visible', 'off');
ax = axes('Parent', fig, 'Position', [0.10 0.10 0.55 0.80]);
hold(ax, 'on');
names = {'^7F_0', '^7F_1', '^7F_2', '^7F_3', '^7F_4', '^7F_5', '^7F_6'};
for k = 1:7
    y = EJ(k);
    plot(ax, [0.2 1.6], [y y], 'k-', 'LineWidth', 1.8);
    text(ax, 1.75, y, sprintf('%s   %d cm^{-1}   g=%d   pop=%.1f%%', ...
        names{k}, EJ(k), gJ(k), 100 * pop(k)), 'FontSize', 8, 'Interpreter', 'tex');
end
plot(ax, [0.2 1.6], [E5D0 E5D0], 'Color', [0.80 0.15 0.12], 'LineWidth', 2.0);
text(ax, 1.75, E5D0, sprintf('^5D_0   %d cm^{-1}', E5D0), 'Color', [0.80 0.15 0.12], ...
    'FontSize', 9, 'FontWeight', 'bold', 'Interpreter', 'tex');
% emission arrows
plot(ax, [0.05 0.05], [E5D0, EJ(2)], 'Color', [0.10 0.45 0.25], 'LineWidth', 1.6);
text(ax, -0.55, (E5D0 + EJ(2)) / 2, {'^5D_0\to^7F_1', '590 nm', 'MD'}, ...
    'FontSize', 8, 'Color', [0.10 0.45 0.25], 'HorizontalAlignment', 'center');
plot(ax, [0.12 0.12], [E5D0, EJ(3)], 'Color', [0.75 0.10 0.10], 'LineWidth', 1.6);
text(ax, 0.55, (E5D0 + EJ(3)) / 2 + 800, {'^5D_0\to^7F_2', '612 nm', 'ED hypersensitive'}, ...
    'FontSize', 8, 'Color', [0.75 0.10 0.10]);
ylim(ax, [-400 18500]);
xlim(ax, [-0.9 6.2]);
ylabel(ax, 'E (cm^{-1})');
set(ax, 'XTick', []);
title(ax, 'Eu^{3+} ^{7}F_J + ^{5}D_0 at 300 K');
orb.styleAxes(ax);
% kT bar on the 7F region — draw in a zoom inset
ax2 = axes('Parent', fig, 'Position', [0.72 0.12 0.24 0.78]);
hold(ax2, 'on'); axis(ax2, 'off');
text(ax2, 0, 0.95, '300 K occupations', 'FontWeight', 'bold', 'FontSize', 11);
text(ax2, 0, 0.82, sprintf('kT = %.0f cm^{-1}', c.kT_cm), 'FontSize', 10, ...
    'Color', [0.80 0.25 0.10]);
text(ax2, 0, 0.70, sprintf('^{7}F_{0}  %.1f %%', 100*pop(1)), 'FontSize', 11);
text(ax2, 0, 0.62, sprintf('^{7}F_{1}  %.1f %%', 100*pop(2)), 'FontSize', 11);
text(ax2, 0, 0.54, sprintf('^{7}F_{2}  %.1f %%', 100*pop(3)), 'FontSize', 11);
text(ax2, 0, 0.42, {'Hot bands from thermally', ...
    'populated ^{7}F_{1} enable', ...
    'luminescence thermometry.', '', ...
    'Binnemans, Coord. Chem. Rev.', ...
    '295, 1 (2015). Beiser 9.2.', '', ...
    'GEST3015 V: Eu^{3+} as a', ...
    'spectroscopic probe / phosphor.'}, 'FontSize', 8);
xlim(ax2, [0 1]); ylim(ax2, [0 1]);
f = fullfile(outDir, 'eu3_ladder_300K.svg');
orb.exportSvg(fig, f, 1000, 780);
close(fig);
end
