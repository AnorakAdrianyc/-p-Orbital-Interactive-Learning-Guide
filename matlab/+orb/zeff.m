function [Z, cite] = zeff(symbol, n, l)
% ZEFF Clementi-Raimondi (1963) / Clementi-Raimondi-Reinhardt (1967) Z_eff.
%
% [Z, cite] = orb.zeff(symbol, n, l)
% symbol is 'Si', 'O', 'Ti', or 'Eu' (neutral-atom SCF values used as a
% hydrogenic scale for the valence orbital of that atom; not an ion-specific
% Hartree-Fock orbital).
%
% References:
%   E. Clementi and D. L. Raimondi, J. Chem. Phys. 38, 2686 (1963).
%   E. Clementi, D. L. Raimondi, W. P. Reinhardt, J. Chem. Phys. 47, 1300 (1967).

symbol = strtrim(symbol);
key = sprintf('%s_n%d_l%d', symbol, n, l);
cite = 'Clementi-Raimondi 1963 / Clementi-Raimondi-Reinhardt 1967';

% Z_eff = zeta * n from the published orbital exponents.
table = { ...
    'Si_n3_l0', 4.9032; ...
    'Si_n3_l1', 4.2852; ...
    'O_n2_l0',  4.4916; ...
    'O_n2_l1',  4.4532; ...
    'Ti_n4_l0', 4.8168; ...
    'Ti_n3_l2', 8.1414; ...
    'Eu_n5_l0', 18.590; ...
    'Eu_n5_l1', 16.555; ...
    'Eu_n4_l3', 24.320};
for k = 1:size(table, 1)
    if strcmp(table{k, 1}, key)
        Z = table{k, 2};
        if strcmp(symbol, 'Eu')
            cite = 'Clementi-Raimondi-Reinhardt, J. Chem. Phys. 47, 1300 (1967)';
        else
            cite = 'Clementi-Raimondi, J. Chem. Phys. 38, 2686 (1963)';
        end
        return;
    end
end
error('zeff:unknown', 'No Clementi-Raimondi Z_eff for %s n=%d l=%d.', symbol, n, l);
end
