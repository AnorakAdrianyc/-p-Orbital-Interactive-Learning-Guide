function [Z, sigma, note] = slaterZeff(symbol, n, l)
% SLATERZEFF Slater-rule Z_eff used as a footnote cross-check (not plotted).
%
% Si 3p: 4.15; O 2p: 4.55; Ti 3d: 3.65. Eu 4f uses the 4f group with
% remaining 4f electrons at 0.35 and all inner groups at 1.00.

symbol = strtrim(symbol);
note = 'Slater 1930 shielding; teaching cross-check only.';
switch symbol
    case 'Si'
        % [Ne] 3s2 3p2; valence n=3 electron.
        % other n=3: 3 * 0.35; n=2: 8 * 0.85; n=1: 2 * 1.00
        sigma = 3 * 0.35 + 8 * 0.85 + 2 * 1.00;
        Z = 14 - sigma;
    case 'O'
        % 1s2 2s2 2p4; 2p electron: other n=2: 5*0.35; n=1: 2*0.85
        sigma = 5 * 0.35 + 2 * 0.85;
        Z = 8 - sigma;
    case 'Ti'
        % [Ar] 3d2 4s2; 3d electron: other 3d 0.35, all to the left 1.00
        % inner = 18 (Ar), other 3d = 1
        sigma = 1 * 0.35 + 18 * 1.00;
        Z = 22 - sigma;
    case 'Eu'
        % Neutral Eu [Xe] 4f7 6s2. For a 4f electron: other 4f = 6*0.35,
        % all groups to the left of (4f) = 1s..4d = 46 electrons at 1.00.
        % 5s,5p,6s sit to the right of 4f in Slater's grouping and do not
        % screen a 4f electron.
        if l == 3
            sigma = 6 * 0.35 + 46 * 1.00;
            Z = 63 - sigma;
        else
            % 5s/5p of the Xe core: n=5 group with 5s2 5p6, inner n=4,3,2,1
            % This is a rough teaching number only.
            sigma = 7 * 0.35 + 8 * 0.85 + 46 * 1.00;
            Z = 63 - sigma;
        end
    otherwise
        error('slaterZeff:symbol', 'No Slater recipe for %s.', symbol);
end
end
