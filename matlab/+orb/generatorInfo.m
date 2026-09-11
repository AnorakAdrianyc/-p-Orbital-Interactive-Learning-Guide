function [gen, verstr] = generatorInfo()
% GENERATORINFO MATLAB vs Octave stamp for manifest.json and figure footers.

if exist('OCTAVE_VERSION', 'builtin') == 5
    gen = 'Octave';
    verstr = version;
else
    gen = 'MATLAB';
    verstr = version;
end
end
