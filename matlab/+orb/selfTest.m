function [ok, report] = selfTest()
% SELFTEST Numeric checks against Beiser 6.7 / 8.5 and Eu3+ 300 K populations.
%
% Checks:
%   * integral P(r) dr ~ 1
%   * r_mp(1s) = a0/Z, r_mp(2p) = 4 a0/Z, r_mp(3d) = 9 a0/Z
%   * n <= 3 radial forms vs closed hydrogenic expressions
%   * real-Y orthonormality on the sphere
%   * sp3 coefficient orthonormality
%   * Eu3+ 7F_J Boltzmann populations at 300 K (~65.7 / 32.0 / 2.2 %)

c = orb.physConst();
tolInt = 2e-3;
tolR = 0.04 * c.a0_Ang;
nFail = 0;
msg = {};

% --- radial normalisation and most-probable r (Beiser Ex. 6.15-6.17) ---
cases = [1 0 1 1; 2 1 1 4; 3 2 1 9; 2 0 1 NaN];
for k = 1:size(cases, 1)
    n = cases(k, 1); l = cases(k, 2); Z = cases(k, 3);
    [P, r, rmp, ~, normP] = orb.radialP(n, l, Z);
    if abs(normP - 1) > tolInt
        nFail = nFail + 1;
        msg{end+1} = sprintf('norm P(n=%d,l=%d)=%.4f', n, l, normP); %#ok<AGROW>
    end
    if isfinite(cases(k, 4))
        target = cases(k, 4) * c.a0_Ang / Z;
        if abs(rmp - target) > tolR
            nFail = nFail + 1;
            msg{end+1} = sprintf('rmp(n=%d,l=%d)=%.4f A, want %.4f', ...
                n, l, rmp, target); %#ok<AGROW>
        end
    end
    % analytic <r> = a0 n^2/Z * [3/2 - l(l+1)/(2 n^2)]
    [~, ~, ~, rmean] = orb.radialP(n, l, Z);
    rmeanA = c.a0_Ang * n^2 / Z * (1.5 - l * (l + 1) / (2 * n^2));
    if abs(rmean - rmeanA) > 0.03 * c.a0_Ang * n^2
        nFail = nFail + 1;
        msg{end+1} = sprintf('<r> n=%d l=%d  got %.4f want %.4f', ...
            n, l, rmean, rmeanA); %#ok<AGROW>
    end
end

% --- Table 6.1 closed forms at a sample point (Z = 1, atomic units via A) ---
r0 = c.a0_Ang;
R1s = orb.radialR(1, 0, 1, r0);
R1sA = 2 * (1 / c.a0_Ang)^(1.5) * exp(-1);
if abs(R1s - R1sA) / abs(R1sA) > 1e-6
    nFail = nFail + 1;
    msg{end+1} = sprintf('1s closed form mismatch: %g vs %g', R1s, R1sA); %#ok<AGROW>
end
R2p = orb.radialR(2, 1, 1, r0);
rho = 1; % Zr / a0 with n=2 uses rho = Zr/a0 = 1 at r = a0
R2pA = (1 / (2 * sqrt(6))) * (1 / c.a0_Ang)^(1.5) * rho * exp(-rho / 2);
if abs(R2p - R2pA) / abs(R2pA) > 1e-5
    nFail = nFail + 1;
    msg{end+1} = sprintf('2p closed form mismatch: %g vs %g', R2p, R2pA); %#ok<AGROW>
end

% --- angular orthonormality ---
th = linspace(0, pi, 90);
ph = linspace(0, 2 * pi, 180);
dth = th(2) - th(1);
dph = ph(2) - ph(1);
[TH, PH] = meshgrid(th, ph);
x = sin(TH) .* cos(PH);
y = sin(TH) .* sin(PH);
z = cos(TH);
w = sin(TH) * dth * dph;
for l = 0:3
    names = orb.angularNames(l);
    nY = numel(names);
    Ys = cell(nY, 1);
    for i = 1:nY
        Ys{i} = orb.realY(names{i}, x, y, z);
    end
    for i = 1:nY
        for j = i:nY
            ip = sum(sum(Ys{i} .* Ys{j} .* w));
            want = double(i == j);
            if abs(ip - want) > 0.03
                nFail = nFail + 1;
                msg{end+1} = sprintf('Y %s·%s = %.3f', names{i}, names{j}, ip); %#ok<AGROW>
            end
        end
    end
end

% --- hybrid coefficient orthonormality ---
[~, ~, C] = orb.hybrid('sp3', 0, 0, 0, 1, 1);
G = C * C';
if max(max(abs(G - eye(4)))) > 1e-12
    nFail = nFail + 1;
    msg{end+1} = 'sp3 coefficients are not orthonormal'; %#ok<AGROW>
end
[~, ~, C2] = orb.hybrid('sp2', 0, 0, 0, 1, 1);
G2 = C2 * C2';
if max(max(abs(G2 - eye(3)))) > 1e-12
    nFail = nFail + 1;
    msg{end+1} = 'sp2 coefficients are not orthonormal'; %#ok<AGROW>
end

% --- Eu3+ 300 K Boltzmann (Binnemans 2015 free-ion 7F_J) ---
EJ = [0, 379, 1043, 1896, 2869, 3912, 4992];
gJ = 2 * (0:6) + 1;
pop = orb.boltzmann(EJ, gJ, 300);
want = [0.657, 0.320, 0.022];
if max(abs(pop(1:3)' - want)) > 0.015
    nFail = nFail + 1;
    msg{end+1} = sprintf('Eu3+ pops %.3f %.3f %.3f', pop(1), pop(2), pop(3)); %#ok<AGROW>
end

% --- Slater cross-check numbers from the plan ---
[Zs, ~] = orb.slaterZeff('Si', 3, 1);
[Zo, ~] = orb.slaterZeff('O', 2, 1);
[Zt, ~] = orb.slaterZeff('Ti', 3, 2);
if abs(Zs - 4.15) > 0.02 || abs(Zo - 4.55) > 0.02 || abs(Zt - 3.65) > 0.02
    nFail = nFail + 1;
    msg{end+1} = sprintf('Slater Zeff Si/O/Ti = %.2f/%.2f/%.2f', Zs, Zo, Zt); %#ok<AGROW>
end

% --- Clementi-Raimondi lookups ---
if abs(orb.zeff('Si', 3, 1) - 4.2852) > 1e-6
    nFail = nFail + 1;
    msg{end+1} = 'Si 3p Zeff lookup failed'; %#ok<AGROW>
end

ok = nFail == 0;
if ok
    report = 'orb.selfTest passed: radial, angular, hybrid, Eu3+ 300 K.';
    disp(report);
else
    lines = msg{1};
    for im = 2:numel(msg)
        lines = sprintf('%s\n  %s', lines, msg{im});
    end
    report = sprintf('orb.selfTest: %d failure(s)\n  %s', nFail, lines);
    warning('selfTest:fail', '%s', report);
end
end
