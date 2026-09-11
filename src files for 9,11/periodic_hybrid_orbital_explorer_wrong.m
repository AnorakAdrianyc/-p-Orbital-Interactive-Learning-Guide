function periodic_hybrid_orbital_explorer_wrong(selectedSymbol)
% PERIODIC_HYBRID_ORBITAL_EXPLORER
% Educational visualization: periodic-table context plus a local hybrid-orbital
% model. Hybridization belongs to a specified bonded atom in a molecule/solid,
% not to an isolated element. Edit selectedSymbol (or call with one) to inspect.
%
% Examples:
%   periodic_hybrid_orbital_explorer
%   periodic_hybrid_orbital_explorer('C')
%   periodic_hybrid_orbital_explorer('Si')
%
% References (IEEE):
% [1] NIST, "Electronic Configurations of the Elements," NIST Physical
%     Measurement Laboratory. https://math.nist.gov/DFTdata/atomdata/configuration.html
% [2] A. Beiser, Concepts of Modern Physics, 6th ed. New York, NY, USA:
%     McGraw-Hill, 2003, ch. 10.

if nargin == 0, selectedSymbol = 'C'; end
E = elementData();
idx = find(strcmpi({E.symbol}, selectedSymbol), 1);
assert(~isempty(idx), 'Use a valid element symbol, e.g. C, Si, Fe, or U.');

fig = figure('Color','w','Name','Periodic Hybrid-Orbital Explorer', ...
    'NumberTitle','off','Position',[80 80 1450 760]);
tiledlayout(fig,1,2,'TileSpacing','compact','Padding','compact');
ax1 = nexttile; drawPeriodicTable(ax1,E,idx);
ax2 = nexttile; drawLocalModel(ax2,E(idx));
end

function drawPeriodicTable(ax,E,selected)
cla(ax); hold(ax,'on'); axis(ax,'equal'); axis(ax,[0 19 0 10]); axis(ax,'off');
title(ax,'Periodic-table context (clicking is not chemical hybridization)','FontWeight','bold');
colors = struct('s',[0.98 .80 .42],'p',[0.98 .52 .45], ...
                'd',[.63 .62 .86],'f',[.88 .90 .42]);
for k = 1:numel(E)
    x = E(k).col; y = 9-E(k).row;
    c = colors.(E(k).block);
    lw = 0.7; edge = [0.15 .15 .15];
    if k == selected, edge = [0 .45 .85]; lw = 3; end
    rectangle(ax,'Position',[x y .95 .9],'FaceColor',c,'EdgeColor',edge,'LineWidth',lw);
    text(ax,x+.06,y+.68,num2str(E(k).Z),'FontSize',7,'FontWeight','bold');
    text(ax,x+.475,y+.38,E(k).symbol,'HorizontalAlignment','center', ...
        'FontSize',12,'FontWeight','bold');
end
text(ax,.1,.2,'Colors show the periodic block whose differentiating electron enters s, p, d or f. This is not a hybridization map.', ...
    'FontSize',9,'Interpreter','none');
end

function drawLocalModel(ax,e)
cla(ax); hold(ax,'on'); axis(ax,'equal'); axis(ax,[-4 4 -4 4 -4 4]); grid(ax,'on');
view(ax,35,25); xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');

[hyb,note] = conventionalCandidate(e);
title(ax,sprintf('%s (Z=%d): %s',e.symbol,e.Z,hyb),'FontWeight','bold');
text(ax,-3.8,-3.6,3.6,{['Periodic block: ',e.block,'; group: ',num2str(e.group)], ...
    ['Model status: ',note], ...
    'Choose the molecular/solid coordination before treating this as physical.'}, ...
    'FontSize',9,'VerticalAlignment','top','BackgroundColor','w');

% Central atom and nucleus
[X,Y,Z] = sphere(36); surf(ax,.38*X,.38*Y,.38*Z,'EdgeColor','none','FaceColor',[.85 .18 .16]);
text(ax,0,0,0,e.symbol,'HorizontalAlignment','center','Color','w','FontWeight','bold');

switch hyb
    case 'sp (linear)'
        dirs = [1 0 0;-1 0 0];
    case 'sp2 (trigonal planar)'
        a = (0:2)'*2*pi/3; dirs = [cos(a) sin(a) zeros(3,1)];
    case 'sp3 (tetrahedral)'
        dirs = [1 1 1;1 -1 -1;-1 1 -1;-1 -1 1]/sqrt(3);
    case 'dsp2 (square planar)'
        dirs = [1 0 0;-1 0 0;0 1 0;0 -1 0];
    case 'sp3d (trigonal bipyramidal)'
        a = (0:2)'*2*pi/3; dirs = [cos(a) sin(a) zeros(3,1);0 0 1;0 0 -1];
    otherwise % sp3d2
        dirs = [1 0 0;-1 0 0;0 1 0;0 -1 0;0 0 1;0 0 -1];
end
for j=1:size(dirs,1)
    d = dirs(j,:);
    [x,y,z] = sphere(22);
    C = [0.1 0.45 0.9] + 0.06*mod(j,2);
    surf(ax, .55*x+1.35*d(1), .55*y+1.35*d(2), .55*z+1.35*d(3), ...
        'FaceColor',C,'FaceAlpha',.78,'EdgeColor','none');
    plot3(ax,[0 2.2*d(1)],[0 2.2*d(2)],[0 2.2*d(3)],'k-','LineWidth',1);
end
camlight(ax,'headlight'); lighting(ax,'gouraud');
end

function [hyb,note] = conventionalCandidate(e)
% This table reports a common *candidate* for teaching examples, not an
% intrinsic elemental label. Transition/inner-transition bonding is diverse.
g = e.group;
if e.Z == 1
    hyb='1s atomic orbital'; note='H has no conventional hybridization by itself.';
elseif e.Z == 2 || g == 18
    hyb='closed-shell; no default'; note='A noble gas has no default bonding geometry.';
elseif ismember(e.symbol,{'B','Al','Ga','In','Tl'})
    hyb='sp2 (trigonal planar)'; note='Common three-coordinate molecular motif; compound-dependent.';
elseif ismember(e.symbol,{'C','Si','Ge','Sn','Pb'})
    hyb='sp3 (tetrahedral)'; note='Common four-coordinate motif; e.g., diamond/Si lattice.';
elseif ismember(e.symbol,{'N','P','As','Sb','Bi'})
    hyb='sp3 (tetrahedral e-pair geometry)'; note='Common 3 bonds + lone-pair motif; oxidation state matters.';
elseif ismember(e.symbol,{'O','S','Se','Te','Po'})
    hyb='sp3 (tetrahedral e-pair geometry)'; note='Common 2 bonds + 2 lone pairs; compound-dependent.';
elseif ismember(e.symbol,{'F','Cl','Br','I','At','Ts'})
    hyb='sp3 (tetrahedral e-pair geometry)'; note='Common 1 bond + 3 lone pairs; compound-dependent.';
elseif ismember(e.block,{'d','f'})
    hyb='coordination-dependent'; note='Do not assign one hybridization: ligand field/MO theory is usually better.';
else
    hyb='coordination-dependent'; note='No reliable default without a compound, charge, and geometry.';
end
% Draw an explicit geometry only for renderable pedagogical categories.
if strcmp(hyb,'coordination-dependent'), hyb='sp3d2 (illustrative only)'; end
end

% {function E = elementData()
%S = {'H','','','','','','','','','','','','','','','','','He'; ...
    % 'Li','Be','','','','','','','','','','','B','C','N','O','F','Ne'; ...
   %  'Na','Mg','','','','','','','','','','','Al','Si','P','S','Cl','Ar'; ...
   %  'K','Ca','Sc','Ti','V','Cr','Mn','Fe','Co','Ni','Cu','Zn','Ga','Ge','As','Se','Br','Kr'; ...
   %  'Rb','Sr','Y','Zr','Nb','Mo','Tc','Ru','Rh','Pd','Ag','Cd','In','Sn','Sb','Te','I','Xe'; ...
   %  'Cs','Ba','La','Hf','Ta','W','Re','Os','Ir','Pt','Au','Hg','Tl','Pb','Bi','Po','At','Rn'; ...
   %  'Fr','Ra','Ac','Rf','Db','Sg','Bh','Hs','Mt','Ds','Rg','Cn','Nh','Fl','Mc','Lv','Ts','Og'};
% Standard long-form layout coordinates (row 1--7, col 1--18).
%coords = {[1 1;1 18], [2 1;2 2;2 13:18], [3 1;3 2;3 13:18], ...
%[4 1:18],[5 1:18],[6 1:18],[7 1:18]};
%E = struct('Z',{},'symbol',{},'row',{},'col',{},'group',{},'block',{}); Z=0;
%for r=1:7
    %row = S{r}; rc = coords{r};
    %for j=1:numel(row)
     %   Z=Z+1; c=rc(j);
     %   E(end+1)=makeElement(Z,row{j},r,c); %#ok<AGROW>
    %end
%end
% Correct labels in displayed main table for f-block placeholders; the La/Ac
% main-table positions remain as standard group-3 display positions.
%for j=1:14
 %   Z=57+j; E(end+1)=makeElement(Z,lan{j},8,j+3); %#ok<AGROW>
%end
%for j=1:14
%    Z=89+j; E(end+1)=makeElement(Z,act{j},9,j+3); %#ok<AGROW>
%end
%end
%
%function e=makeElement(Z,s,r,c)
%e=struct('Z',Z,'symbol',s,'row',r,'col',c,'group',c,'block','p');
%if r>=8, e.block='f'; e.group=0; return; end
%if c<=2, e.block='s'; elseif c>=13, e.block='p'; else, e.block='d'; end
%if strcmp(s,'He'), e.block='s'; end
%end
function E = elementData()
% Define S as a proper ragged cell array using nested curly braces
S = {{'H','He'}; ...
    {'Li','Be','B','C','N','O','F','Ne'}; ...
    {'Na','Mg','Al','Si','P','S','Cl','Ar'}; ...
    {'K','Ca','Sc','Ti','V','Cr','Mn','Fe','Co','Ni','Cu','Zn','Ga','Ge','As','Se','Br','Kr'}; ...
    {'Rb','Sr','Y','Zr','Nb','Mo','Tc','Ru','Rh','Pd','Ag','Cd','In','Sn','Sb','Te','I','Xe'}; ...
    {'Cs','Ba','La','Hf','Ta','W','Re','Os','Ir','Pt','Au','Hg','Tl','Pb','Bi','Po','At','Rn'}; ...
    {'Fr','Ra','Ac','Rf','Db','Sg','Bh','Hs','Mt','Ds','Rg','Cn','Nh','Fl','Mc','Lv','Ts','Og'}};

lan = {'Ce','Pr','Nd','Pm','Sm','Eu','Gd','Tb','Dy','Ho','Er','Tm','Yb','Lu'};
act = {'Th','Pa','U','Np','Pu','Am','Cm','Bk','Cf','Es','Fm','Md','No','Lr'};

% Clean up coords to be simple lists of column indices for each row
coords = {[1, 18], [1, 2, 13:18], [1, 2, 13:18], 1:18, 1:18, 1:18, 1:18};

E = struct('Z',{},'symbol',{},'row',{},'col',{},'group',{},'block',{}); Z=0;
for r=1:7
    row = S{r}; rc = coords{r};
    for j=1:numel(row)
        Z=Z+1; c=rc(j);
        E(end+1)=makeElement(Z,row{j},r,c); %#ok<AGROW>
    end
end
% Correct labels in displayed main table for f-block placeholders; the La/Ac
% main-table positions remain as standard group-3 display positions.
for j=1:14
    Z=57+j; E(end+1)=makeElement(Z,lan{j},8,j+3); %#ok<AGROW>
end
for j=1:14
    Z=89+j; E(end+1)=makeElement(Z,act{j},9,j+3); %#ok<AGROW>
end
end
