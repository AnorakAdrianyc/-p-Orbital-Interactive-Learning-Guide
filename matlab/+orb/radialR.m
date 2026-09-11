function R = radialR(n, l, zeff, rAng)
% RADIALR Hydrogenic radial wave function R_nl(r) with effective nuclear charge.
%
% R = orb.radialR(n, l, zeff, rAng) returns the normalized radial function
% using associated Laguerre polynomials (Beiser Table 6.1 convention for
% n <= 3). rAng is the radial coordinate in Angstrom. The volume element
% is r^2 dr, so integral r^2 R^2 dr = 1.
%
% rho = 2 Z_eff r / (n a0);  R = N exp(-rho/2) rho^l L_{n-l-1}^{2l+1}(rho)

if n < 1 || l < 0 || l >= n
    error('radialR:quantum', 'Require n >= 1 and 0 <= l < n.');
end
if zeff <= 0
    error('radialR:zeff', 'Z_eff must be positive.');
end

c = orb.physConst();
a0 = c.a0_Ang;
r = max(rAng, 0);
rho = 2 * zeff .* r ./ (n * a0);

k = n - l - 1;
alpha = 2 * l + 1;
Lval = assocLaguerre(k, alpha, rho);

pref = (2 * zeff / (n * a0))^3;
N = sqrt(pref * nfact(k) / (2 * n * nfact(n + l)));

% rho^l = 0 at the origin for l > 0; keep R finite.
rhoL = ones(size(rho));
if l > 0
    rhoL = rho.^l;
    rhoL(r == 0) = 0;
end

R = N .* exp(-rho / 2) .* rhoL .* Lval;
R(~isfinite(R)) = 0;
end

function L = assocLaguerre(k, alpha, x)
% Associated Laguerre L_k^{(alpha)}(x) for integer k, alpha >= 0.
L = zeros(size(x));
if k < 0
    return;
end
for m = 0:k
    C = nfact(k + alpha) / (nfact(k - m) * nfact(alpha + m) * nfact(m));
    L = L + ((-1)^m) * C * (x.^m);
end
end

function f = nfact(n)
if n <= 1
    f = 1;
else
    f = prod(1:n);
end
end
