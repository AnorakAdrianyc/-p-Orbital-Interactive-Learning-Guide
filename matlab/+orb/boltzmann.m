function [pop, kT, Zpart] = boltzmann(E, g, T)
% BOLTZMANN Thermal populations p_i = g_i exp(-E_i / kT) / Z (Beiser 9.2).
%
% [pop, kT, Zpart] = orb.boltzmann(E, g, T)
%   E - level energies, same units as kT (eV or cm^-1)
%   g - degeneracies (2J+1 for a free-ion J level)
%   T - kelvin (default 300)
%
% kT is returned in the same units as E: pass E in cm^-1 to get kT in cm^-1.

c = orb.physConst();
if nargin < 3 || isempty(T)
    T = c.T_K;
end
E = E(:);
g = g(:);
if numel(g) ~= numel(E)
    error('boltzmann:size', 'E and g must have the same length.');
end
% Infer unit from magnitude: Eu ladders are hundreds of cm^-1; band gaps are eV.
if max(E) > 50
    kT = c.kB_cm * T;
else
    kT = c.kB_eV * T;
end
w = g .* exp(-E / kT);
Zpart = sum(w);
pop = w / Zpart;
end
