function outDir = defaultExportDir()
% DEFAULTEXPORTDIR svg/matlab_export relative to the repository root.

here = fileparts(mfilename('fullpath'));  % matlab/+orb
matlabDir = fileparts(here);
root = fileparts(matlabDir);
outDir = fullfile(root, 'svg', 'matlab_export');
if exist(outDir, 'dir') ~= 7
    mkdir(outDir);
end
end
