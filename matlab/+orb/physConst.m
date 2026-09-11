function c = physConst()
% PHYSCONST Physical constants used by the orbital-atlas figures.
%
% Returns a struct with Bohr radius in Angstrom, Boltzmann constant in
% eV/K and cm^-1/K, and hc in eV·nm. T = 300 K is the room-temperature
% convention used throughout GEST3015 sheets (kT changes < 3% over 293-298 K).

c.a0_Ang = 0.529177210903;
c.kB_eV = 8.617333262145e-5;
c.kB_cm = 0.695034800;
c.hc_eVnm = 1239.84193;
c.T_K = 300;
c.kT_eV = c.kB_eV * c.T_K;
c.kT_meV = 1000 * c.kT_eV;
c.kT_cm = c.kB_cm * c.T_K;
end
