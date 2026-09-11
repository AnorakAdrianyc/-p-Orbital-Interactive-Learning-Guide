function f = kt_scale_svg(outDir)
% KT_SCALE_SVG One energy axis comparing kT(300 K) with Si, TiO2 and Eu3+.

if nargin < 1 || isempty(outDir)
    outDir = orb.defaultExportDir();
end
if exist(outDir, 'dir') ~= 7
    mkdir(outDir);
end
orb.prepareGraphics();

c = orb.physConst();
kT = c.kT_eV;
SiEg = 1.12;
TiR = 3.00;
TiA = 3.20;
EuF1 = 379 / 8065.54429;   % cm^-1 -> eV
EuD0 = 17227 / 8065.54429;

items = { ...
    kT,   [0.80 0.25 0.10], 'kT (300 K) = 25.9 meV = 208 cm^{-1}'; ...
    EuF1, [0.55 0.20 0.65], 'Eu^{3+} ^{7}F_{0}\rightarrow^{7}F_{1}  (379 cm^{-1})'; ...
    SiEg, [0.15 0.45 0.80], 'Si E_g = 1.12 eV  (E_g/kT \approx 43)'; ...
    EuD0, [0.75 0.15 0.15], 'Eu^{3+} ^{5}D_{0}  (17227 cm^{-1} \approx 2.14 eV)'; ...
    TiR,  [0.80 0.35 0.12], 'TiO_2 rutile E_g = 3.0 eV  (\approx 413 nm)'; ...
    TiA,  [0.85 0.55 0.10], 'TiO_2 anatase E_g = 3.2 eV  (\approx 388 nm)'};

fig = figure('Color', 'w', 'Visible', 'off');
ax = axes('Parent', fig); hold(ax, 'on');
% log x-axis via plotting log10(E)
for k = 1:size(items, 1)
    E = items{k, 1};
    col = items{k, 2};
    lab = items{k, 3};
    y = size(items, 1) + 1 - k;
    plot(ax, [log10(kT) log10(E)], [y y], '-', 'Color', col, 'LineWidth', 2.2);
    plot(ax, log10(E), y, 'o', 'MarkerFaceColor', col, 'MarkerEdgeColor', 'k', ...
        'MarkerSize', 8);
    text(ax, log10(E) + 0.04, y, lab, 'FontSize', 9, 'VerticalAlignment', 'middle');
end
% kT reference line
plot(ax, [log10(kT) log10(kT)], [0.4 size(items,1)+0.6], '--', ...
    'Color', [0.80 0.25 0.10], 'LineWidth', 1.0);
xlabel(ax, 'log_{10} E (eV)');
set(ax, 'YTick', []);
ylim(ax, [0.3 size(items, 1) + 0.8]);
xlim(ax, [log10(kT) - 0.3, log10(TiA) + 1.8]);
title(ax, 'Room-temperature energy scale: kT vs gaps and Eu^{3+} levels');
orb.styleAxes(ax);
text(ax, 0.02, -0.16, ...
    'Orbital shapes do not change with T. Temperature enters occupation (Fermi-Dirac / Boltzmann) and 300 K lattice constants.', ...
    'Units', 'normalized', 'FontSize', 8);
f = fullfile(outDir, 'kt_scale.svg');
orb.exportSvg(fig, f, 1100, 520);
close(fig);
end
