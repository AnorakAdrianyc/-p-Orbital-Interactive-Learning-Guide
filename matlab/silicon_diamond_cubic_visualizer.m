function silicon_diamond_cubic_visualizer(aAngstrom)
% SILICON_DIAMOND_CUBIC_VISUALIZER
% Visualises a local diamond-cubic Si environment: a central Si atom, its
% four nearest Si neighbours, and the conventional cubic unit-cell outline.
%
% Usage:
%   silicon_diamond_cubic_visualizer
%   silicon_diamond_cubic_visualizer(5.431)
%
% Scientific scope
% - This is an ideal diamond-cubic silicon structural model, not an orbital
%   wavefunction or a DFT calculation.
% - Each Si has four nearest Si neighbours in a tetrahedral arrangement.
% - The local tetrahedral arrangement is often described using sp3-like
%   bonding directions, but the semiconductor is an extended covalent crystal
%   whose electronic properties are described by energy-band theory.
% - The default lattice parameter is a = 5.431 Angstrom, a representative
%   room-temperature value. Change it if your cited experimental source gives
%   a temperature- or strain-specific value.
%
% Academic references
% [1] G. D. Cody, "The optical constants of crystalline silicon," in
%     Handbook of Optical Constants of Solids, E. D. Palik, Ed. Academic,
%     1985. (For temperature-dependent Si optical/electronic data.)
% [2] A. Beiser, Concepts of Modern Physics, 6th ed. McGraw-Hill, 2003,
%     ch. 10. (Solid-state and semiconductor background.)
% [3] Review literature on diamond-cubic Si identifies it as a fourfold
%     coordinated, indirect-gap semiconductor. Verify the specific lattice
%     parameter used against a current crystallographic data source.

if nargin < 1
    aAngstrom = 5.431;
end
validateattributes(aAngstrom, {'numeric'}, {'scalar','positive','finite'});

% Conventional diamond-cubic cell: fcc lattice + (1/4,1/4,1/4) basis.
fcc = [0 0 0;
       0 .5 .5;
       .5 0 .5;
       .5 .5 0];
basis = [0 0 0;
         .25 .25 .25];
frac = zeros(8,3);
n = 0;
for i = 1:size(fcc,1)
    for j = 1:size(basis,1)
        n = n + 1;
        frac(n,:) = mod(fcc(i,:) + basis(j,:), 1);
    end
end
centralIndex = find(all(abs(frac - [.25 .25 .25]) < 1e-12, 2), 1);
assert(~isempty(centralIndex), 'Central basis atom was not found.');

% Replicate cells to identify the four periodic nearest neighbours exactly.
translations = -1:1;
allPos = [];
for ix = translations
    for iy = translations
        for iz = translations
            allPos = [allPos; (frac + [ix iy iz]) * aAngstrom]; %#ok<AGROW>
        end
    end
end
central = frac(centralIndex,:) * aAngstrom;
distances = vecnorm(allPos - central, 2, 2);
nearestDistance = sqrt(3) * aAngstrom / 4;
tol = 1e-8 * aAngstrom;
neighborPos = allPos(abs(distances - nearestDistance) < tol, :);
assert(size(neighborPos,1) == 4, 'Expected exactly four tetrahedral neighbours.');

% Plot only atoms in the central conventional cell, plus periodic neighbours
% that demonstrate bonds crossing the displayed cell boundary.
inside = all(frac >= -1e-12 & frac <= 1+1e-12, 2);
cellAtoms = frac(inside,:) * aAngstrom;

figure('Color','w','Name','Diamond-cubic silicon: local coordination', ...
       'NumberTitle','off','Position',[120 100 1080 760]);
ax = axes; hold(ax,'on'); axis(ax,'equal'); grid(ax,'on'); view(ax,34,23);
xlabel(ax,'x (Angstrom)'); ylabel(ax,'y (Angstrom)'); zlabel(ax,'z (Angstrom)');
title(ax,'Diamond-cubic silicon: local tetrahedral coordination', 'FontWeight','bold');

% Unit-cell edges.
vertices = aAngstrom * [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1];
edges = [1 2;2 3;3 4;4 1;5 6;6 7;7 8;8 5;1 5;2 6;3 7;4 8];
for e = 1:size(edges,1)
    p1 = vertices(edges(e,1),:); p2 = vertices(edges(e,2),:);
    plot3(ax,[p1(1) p2(1)],[p1(2) p2(2)],[p1(3) p2(3)], ...
          'Color',[.25 .25 .25],'LineWidth',0.8);
end

% All conventional-cell atoms except the selected local central atom.
otherAtoms = cellAtoms(vecnorm(cellAtoms-central,2,2) > tol,:);
scatter3(ax,otherAtoms(:,1),otherAtoms(:,2),otherAtoms(:,3), ...
         170,[.64 .70 .78],'filled','MarkerEdgeColor',[.2 .2 .2]);

% Four tetrahedral neighbours and bonds.
for k = 1:4
    p = neighborPos(k,:);
    plot3(ax,[central(1) p(1)],[central(2) p(2)],[central(3) p(3)], ...
          'Color',[.05 .28 .68],'LineWidth',2.4);
    scatter3(ax,p(1),p(2),p(3),260,[.10 .42 .88],'filled', ...
             'MarkerEdgeColor',[.05 .12 .25]);
end

% Selected central atom.
scatter3(ax,central(1),central(2),central(3),360,[.84 .18 .14], ...
         'filled','MarkerEdgeColor',[.25 .04 .04]);
text(ax,central(1),central(2),central(3)+.35,'Central Si', ...
     'HorizontalAlignment','center','FontWeight','bold');

% Information panel. Bond length follows from ideal cubic geometry.
bondLength = nearestDistance;
bondAngle = acosd(-1/3);
info = { ...
    sprintf('Ideal conventional cubic cell: a = %.4f Angstrom',aAngstrom), ...
    sprintf('Nearest-neighbour Si-Si distance: sqrt(3)a/4 = %.4f Angstrom',bondLength), ...
    sprintf('Tetrahedral bond angle: %.3f degrees',bondAngle), ...
    'Red: selected Si atom; blue: its four nearest Si neighbours.', ...
    'Grey: other atoms in the conventional diamond-cubic cell.', ...
    'This is an ideal crystal structure, not an orbital or band-structure calculation.', ...
    'Use band theory for Si electronic properties; Si has an indirect band gap.'};
text(ax,-.18*aAngstrom,-.18*aAngstrom,1.19*aAngstrom,info, ...
     'VerticalAlignment','top','FontSize',9,'BackgroundColor','w');

xlim(ax,[-.25 1.25]*aAngstrom);
ylim(ax,[-.25 1.25]*aAngstrom);
zlim(ax,[-.25 1.25]*aAngstrom);
camlight(ax,'headlight'); lighting(ax,'gouraud');

fprintf('Diamond-cubic Si model\n');
fprintf('a = %.6f Angstrom\n',aAngstrom);
fprintf('Ideal nearest-neighbour Si-Si distance = %.6f Angstrom\n',bondLength);
fprintf('Ideal tetrahedral angle = %.6f degrees\n',bondAngle);
end
