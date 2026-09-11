function manifest = make_orbital_atlas_svgs(outDir)
% MAKE_ORBITAL_ATLAS_SVGS Run self-test and export every atlas panel to SVG.
%
%   make_orbital_atlas_svgs
%   make_orbital_atlas_svgs('/path/to/svg/matlab_export')
%
% Writes svg/matlab_export/*.svg and manifest.json. Run this in MATLAB
% R2026a on the machine that produces the course figures; Octave is used
% only for CI previews and stamps generator=Octave in the manifest.

thisDir = fileparts(mfilename('fullpath'));
addpath(thisDir);
orb.prepareGraphics();

if nargin < 1 || isempty(outDir)
    outDir = orb.defaultExportDir();
end
if exist(outDir, 'dir') ~= 7
    mkdir(outDir);
end

fprintf('Running orb.selfTest ...\n');
[ok, report] = orb.selfTest();
if ~ok
    error('make_orbital_atlas_svgs:selfTest', '%s', report);
end

files = {};
fprintf('Si panels ...\n');
files = [files, si_orbital_atlas_svg(outDir)];
fprintf('TiO2 panels ...\n');
files = [files, tio2_orbital_atlas_svg(outDir)];
fprintf('Eu3+ panels ...\n');
files = [files, eu3_orbital_atlas_svg(outDir)];
fprintf('kT scale ...\n');
files{end+1} = kt_scale_svg(outDir);

[gen, verstr] = orb.generatorInfo();
c = orb.physConst();
manifest = struct();
manifest.generated_at = datestr(now, 31);
manifest.generator = gen;
manifest.version = verstr;
manifest.temperature_K = c.T_K;
manifest.kT_meV = c.kT_meV;
manifest.kT_cm_inv = c.kT_cm;
manifest.self_test = report;
manifest.scope = ['Hydrogenic Z_eff clouds and idealised geometries. ', ...
    'Not DFT, not crystallographic coordinates, not a hybridization map for d/f-block.'];
manifest.zeff = struct( ...
    'Si_3s', orb.zeff('Si', 3, 0), ...
    'Si_3p', orb.zeff('Si', 3, 1), ...
    'O_2s',  orb.zeff('O', 2, 0), ...
    'O_2p',  orb.zeff('O', 2, 1), ...
    'Ti_3d', orb.zeff('Ti', 3, 2), ...
    'Ti_4s', orb.zeff('Ti', 4, 0), ...
    'Eu_4f', orb.zeff('Eu', 4, 3), ...
    'Eu_5s', orb.zeff('Eu', 5, 0), ...
    'Eu_5p', orb.zeff('Eu', 5, 1));
manifest.slater_zeff = struct( ...
    'Si_3p', orb.slaterZeff('Si', 3, 1), ...
    'O_2p',  orb.slaterZeff('O', 2, 1), ...
    'Ti_3d', orb.slaterZeff('Ti', 3, 2));
base = {};
for k = 1:numel(files)
    [~, name, ext] = fileparts(files{k});
    base{end+1} = [name ext]; %#ok<AGROW>
end
manifest.files = base;

manPath = fullfile(outDir, 'manifest.json');
writeManifest(manPath, manifest);
fprintf('Wrote %d SVGs and %s\n', numel(base), manPath);
end

function writeManifest(path, S)
fid = fopen(path, 'w');
if fid < 0
    error('make_orbital_atlas_svgs:io', 'Cannot write %s', path);
end
fprintf(fid, '{\n');
fprintf(fid, '  "generated_at": "%s",\n', esc(S.generated_at));
fprintf(fid, '  "generator": "%s",\n', esc(S.generator));
fprintf(fid, '  "version": "%s",\n', esc(S.version));
fprintf(fid, '  "temperature_K": %g,\n', S.temperature_K);
fprintf(fid, '  "kT_meV": %.6g,\n', S.kT_meV);
fprintf(fid, '  "kT_cm_inv": %.6g,\n', S.kT_cm_inv);
fprintf(fid, '  "self_test": "%s",\n', esc(S.self_test));
fprintf(fid, '  "scope": "%s",\n', esc(S.scope));
fprintf(fid, '  "zeff": {\n');
z = S.zeff;
zn = fieldnames(z);
for i = 1:numel(zn)
    comma = ',';
    if i == numel(zn), comma = ''; end
    fprintf(fid, '    "%s": %.6g%s\n', zn{i}, z.(zn{i}), comma);
end
fprintf(fid, '  },\n');
fprintf(fid, '  "slater_zeff": {\n');
z = S.slater_zeff;
zn = fieldnames(z);
for i = 1:numel(zn)
    comma = ',';
    if i == numel(zn), comma = ''; end
    fprintf(fid, '    "%s": %.6g%s\n', zn{i}, z.(zn{i}), comma);
end
fprintf(fid, '  },\n');
fprintf(fid, '  "files": [\n');
for i = 1:numel(S.files)
    comma = ',';
    if i == numel(S.files), comma = ''; end
    fprintf(fid, '    "%s"%s\n', S.files{i}, comma);
end
fprintf(fid, '  ]\n');
fprintf(fid, '}\n');
fclose(fid);
end

function s = esc(s)
s = strrep(s, '\', '\\');
s = strrep(s, '"', '\"');
s = strrep(s, sprintf('\n'), ' ');
end
