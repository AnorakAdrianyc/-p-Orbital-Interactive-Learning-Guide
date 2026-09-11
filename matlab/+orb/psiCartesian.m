function psi = psiCartesian(n, l, zeff, angName, x, y, z)
% PSICARTESIAN Hydrogenic psi(r) = R_nl(r) Y_real(theta, phi) on a grid.

r = sqrt(x.^2 + y.^2 + z.^2);
R = orb.radialR(n, l, zeff, r);
Y = orb.realY(angName, x, y, z);
psi = R .* Y;
end
