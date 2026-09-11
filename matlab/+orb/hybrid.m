function [psi, labels, coeffs] = hybrid(kind, x, y, z, Rs, Rp)
% HYBRID Evaluate sp / sp2 / sp3 hybrid orbitals on a Cartesian grid.
%
% [psi, labels, coeffs] = orb.hybrid(kind, x, y, z, Rs, Rp)
%   kind  - 'sp', 'sp2' or 'sp3' (Beiser 8.5 / GEST3015 L2)
%   Rs,Rp - radial R_s(r) and R_p(r) evaluated on the same grid as x,y,z
%   psi   - cell array, one hybrid wavefunction per entry (size matches x)
%
% sp3 (Beiser / L2 lecture):
%   psi1 = 1/2 (s + px + py + pz)
%   psi2 = 1/2 (s + px - py - pz)
%   psi3 = 1/2 (s - px + py - pz)
%   psi4 = 1/2 (s - px - py + pz)

kind = lower(strtrim(kind));
kind = strrep(kind, '^', '');
sA  = Rs .* orb.realY('s',  x, y, z);
pxA = Rp .* orb.realY('px', x, y, z);
pyA = Rp .* orb.realY('py', x, y, z);
pzA = Rp .* orb.realY('pz', x, y, z);

switch kind
    case 'sp'
        coeffs = [ ...
            1, 0, 0,  1; ...
            1, 0, 0, -1] / sqrt(2);
        labels = {'sp_a'; 'sp_b'};
    case {'sp2', 'sp^2'}
        coeffs = [ ...
            sqrt(1/3),  sqrt(2/3),  0,         0; ...
            sqrt(1/3), -sqrt(1/6),  sqrt(1/2), 0; ...
            sqrt(1/3), -sqrt(1/6), -sqrt(1/2), 0];
        labels = {'sp2_a'; 'sp2_b'; 'sp2_c'};
    case {'sp3', 'sp^3'}
        coeffs = 0.5 * [ ...
             1,  1,  1,  1; ...
             1,  1, -1, -1; ...
             1, -1,  1, -1; ...
             1, -1, -1,  1];
        labels = {'sp3_1'; 'sp3_2'; 'sp3_3'; 'sp3_4'};
    otherwise
        error('hybrid:kind', 'kind must be sp, sp2, or sp3.');
end

nH = size(coeffs, 1);
psi = cell(nH, 1);
for i = 1:nH
    psi{i} = coeffs(i, 1) * sA + coeffs(i, 2) * pxA ...
           + coeffs(i, 3) * pyA + coeffs(i, 4) * pzA;
end
end
