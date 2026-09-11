function dirs = tetraDirs()
% TETRADIRS Unit vectors of a regular tetrahedron (sp3, Beiser Fig. 8.13).
% Bond angle arccos(-1/3) = 109.471 deg.

dirs = [ 1,  1,  1; ...
         1, -1, -1; ...
        -1,  1, -1; ...
        -1, -1,  1];
n = sqrt(sum(dirs.^2, 2));
dirs = dirs ./ [n n n];
end
