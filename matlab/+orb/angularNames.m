function names = angularNames(l)
% ANGULARNAMES Canonical real-harmonic labels for a given l.

switch l
    case 0
        names = {'s'};
    case 1
        names = {'px'; 'py'; 'pz'};
    case 2
        names = {'dz2'; 'dxz'; 'dyz'; 'dxy'; 'dx2-y2'};
    case 3
        names = {'fz3'; 'fxz2'; 'fyz2'; 'fxyz'; 'fz(x2-y2)'; ...
                 'fx(x2-3y2)'; 'fy(3x2-y2)'};
    otherwise
        error('angularNames:l', 'l must be 0, 1, 2 or 3.');
end
end
