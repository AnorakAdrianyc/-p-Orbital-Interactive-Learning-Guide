classdef idgeometryexplorer
% IDGEOMETRYEXPLORER
% One-file periodic-table and idealised coordination-geometry visualizer.
% Save this file exactly as: idgeometryexplorer.m
%
% Quick start:
%   idgeometryexplorer.validateElementData()
%   idgeometryexplorer.plotPeriodicTable('Si')
%   idgeometryexplorer.plotComplex('Fe',2,'d^6',repmat("H2O",6,1), ...
%       'octahedral','Illustrative weak-field Fe(II) case; use LFT/MO.')
%   idgeometryexplorer.runExamples()
%
% Scope: ligand positions and idealised coordination polyhedra only. These
% plots are not orbital wavefunctions, DFT predictions, or XRD structures.

    methods(Static)
        function E = elementData()
            E = struct('Z',{},'symbol',{},'row',{},'col',{},'block',{},'series',{});
            E = idgeometryexplorer.addElements(E,1,{'H','He'},[1,18],[1,2]);
            E = idgeometryexplorer.addElements(E,2,{'Li','Be','B','C','N','O','F','Ne'},[1,2,13,14,15,16,17,18],3:10);
            E = idgeometryexplorer.addElements(E,3,{'Na','Mg','Al','Si','P','S','Cl','Ar'},[1,2,13,14,15,16,17,18],11:18);
            E = idgeometryexplorer.addElements(E,4,{'K','Ca','Sc','Ti','V','Cr','Mn','Fe','Co','Ni','Cu','Zn','Ga','Ge','As','Se','Br','Kr'},1:18,19:36);
            E = idgeometryexplorer.addElements(E,5,{'Rb','Sr','Y','Zr','Nb','Mo','Tc','Ru','Rh','Pd','Ag','Cd','In','Sn','Sb','Te','I','Xe'},1:18,37:54);
            E = idgeometryexplorer.addElements(E,6,{'Cs','Ba','La','Hf','Ta','W','Re','Os','Ir','Pt','Au','Hg','Tl','Pb','Bi','Po','At','Rn'},1:18,[55,56,57,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86]);
            E = idgeometryexplorer.addElements(E,7,{'Fr','Ra','Ac','Rf','Db','Sg','Bh','Hs','Mt','Ds','Rg','Cn','Nh','Fl','Mc','Lv','Ts','Og'},1:18,[87,88,89,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118]);
            E = idgeometryexplorer.addElements(E,8,{'Ce','Pr','Nd','Pm','Sm','Eu','Gd','Tb','Dy','Ho','Er','Tm','Yb','Lu'},4:17,58:71);
            E = idgeometryexplorer.addElements(E,9,{'Th','Pa','U','Np','Pu','Am','Cm','Bk','Cf','Es','Fm','Md','No','Lr'},4:17,90:103);
            for k = 1:numel(E)
                E(k).block = idgeometryexplorer.blockOf(E(k));
                E(k).series = idgeometryexplorer.seriesOf(E(k));
            end
        end

        function validateElementData()
            E = idgeometryexplorer.elementData();
            assert(numel(E) == 118,'Dataset must contain exactly 118 elements.');
            assert(numel(unique([E.Z])) == 118,'Atomic numbers must be unique.');
            assert(isequal(sort([E.Z]),1:118),'Z must contain every integer from 1 to 118.');
            check = {'C',6;'Fe',26;'La',57;'Ce',58;'Lu',71;'Hf',72;'Au',79;'Rn',86;'Ac',89;'Th',90;'Lr',103;'Rf',104;'Og',118};
            for k = 1:size(check,1)
                assert(idgeometryexplorer.elementZ(E,check{k,1}) == check{k,2}, ...
                    'Atomic-number validation failed for %s.',check{k,1});
            end
            disp('Passed: 118 unique elements; Z = 1 through 118; key checks correct.');
        end

        function plotPeriodicTable(selectedSymbol)
            if nargin < 1, selectedSymbol = 'Si'; end
            E = idgeometryexplorer.elementData();
            selected = find(strcmpi({E.symbol},selectedSymbol),1);
            assert(~isempty(selected),'Unknown element symbol: %s.',selectedSymbol);
            figure('Color','w','Name','Periodic-table context','NumberTitle','off','Position',[100 100 1150 650]);
            ax = axes; hold(ax,'on'); axis(ax,'equal'); axis(ax,[0 19 0 10]); axis(ax,'off');
            title(ax,'Periodic-table context: periodic block is not a hybridization assignment','FontWeight','bold');
            for k = 1:numel(E)
                x = E(k).col; y = 9-E(k).row; edge = [.2 .2 .2]; width = .7;
                if k == selected, edge = [0 .42 .85]; width = 2.8; end
                rectangle(ax,'Position',[x y .95 .9],'FaceColor',idgeometryexplorer.blockColor(E(k).block),'EdgeColor',edge,'LineWidth',width);
                text(ax,x+.06,y+.68,num2str(E(k).Z),'FontSize',7,'FontWeight','bold');
                text(ax,x+.475,y+.37,E(k).symbol,'HorizontalAlignment','center','FontSize',11,'FontWeight','bold');
            end
            text(ax,.2,.2,{'s: yellow; p: salmon; d: lavender; f: light green.','Block colour is not a bonding, orbital, or hybridization assignment.'},'FontSize',9);
        end

        function plotComplex(metal,oxidationState,electronCount,ligands,geometry,electronicNote)
            if nargin < 6 || strlength(string(electronicNote)) == 0
                electronicNote = 'Electronic structure requires ligand-field/molecular-orbital analysis.';
            end
            [dirs,label] = idgeometryexplorer.geometry(geometry);
            if ischar(ligands) || (isstring(ligands) && isscalar(ligands))
                ligands = repmat(string(ligands),size(dirs,1),1);
            else
                ligands = string(ligands(:));
            end
            assert(numel(ligands) == size(dirs,1),'Ligand labels must equal the coordination number.');
            figure('Color','w','Name','Idealised coordination geometry','NumberTitle','off','Position',[150 100 900 720]);
            ax = axes; hold(ax,'on'); axis(ax,'equal'); axis(ax,[-4 4 -4 4 -4 4]); grid(ax,'on'); view(ax,35,25);
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            title(ax,sprintf('%s(%+d), %s — %s',metal,oxidationState,electronCount,label),'FontWeight','bold');
            [X,Y,Z] = sphere(36);
            surf(ax,.42*X,.42*Y,.42*Z,'FaceColor',[.78 .15 .15],'EdgeColor','none');
            text(ax,0,0,0,metal,'Color','w','FontWeight','bold','HorizontalAlignment','center');
            for k = 1:size(dirs,1)
                p = 2.05*dirs(k,:);
                plot3(ax,[0 p(1)],[0 p(2)],[0 p(3)],'k-','LineWidth',1.6);
                surf(ax,.28*X+p(1),.28*Y+p(2),.28*Z+p(3),'FaceColor',[.10 .42 .88],'EdgeColor','none');
                text(ax,p(1),p(2),p(3)+.36,ligands(k),'HorizontalAlignment','center','FontWeight','bold');
            end
            note = {'Idealised ligand-position / coordination-polyhedron model.';'Not crystallographic coordinates and not a universal hybridization assignment.';char(string(electronicNote))};
            text(ax,-3.8,-3.8,3.5,note,'FontSize',9,'VerticalAlignment','top','BackgroundColor','w');
            camlight(ax,'headlight'); lighting(ax,'gouraud');
        end

        function runExamples()
            idgeometryexplorer.validateElementData();
            idgeometryexplorer.plotPeriodicTable('Si');
            idgeometryexplorer.plotComplex('Fe',2,'d^6',repmat("H2O",6,1),'octahedral','Illustrative weak-field Fe(II) case; high spin is often favoured.');
            idgeometryexplorer.plotComplex('Pt',2,'d^8',repmat("Cl-",4,1),'square planar','Square-planar d^8 chemistry requires ligand-field/MO analysis.');
            idgeometryexplorer.plotComplex('Eu',3,'4f^6',repmat("O donor",8,1),'square antiprismatic','Generic Ln(III) CN=8 model; actual geometry is ligand-dependent.');
        end

        function [dirs,label] = geometry(name)
            if iscell(name)
                name = name{1};
            end
            name = lower(char(name));
            name = strrep(strrep(name, '-', ''), ' ', '');
            switch name
                case 'linear'
                    dirs = [0 0 1;0 0 -1]; label = 'Linear, CN = 2';
                case 'tetrahedral'
                    dirs = [1 1 1;1 -1 -1;-1 1 -1;-1 -1 1]/sqrt(3); label = 'Tetrahedral, CN = 4';
                case 'squareplanar'
                    dirs = [1 0 0;-1 0 0;0 1 0;0 -1 0]; label = 'Square planar, CN = 4';
                case 'trigonalbipyramidal'
                    t = (0:2)'*2*pi/3; dirs = [cos(t) sin(t) zeros(3,1);0 0 1;0 0 -1]; label = 'Trigonal bipyramidal, CN = 5';
                case 'squarepyramidal'
                    dirs = [1 0 0;-1 0 0;0 1 0;0 -1 0;0 0 1]; label = 'Square pyramidal, CN = 5';
                case 'octahedral'
                    dirs = [1 0 0;-1 0 0;0 1 0;0 -1 0;0 0 1;0 0 -1]; label = 'Octahedral, CN = 6';
                case 'trigonalprismatic'
                    t = (0:2)'*2*pi/3; lowerFace = [cos(t) sin(t) -ones(3,1)]; upperFace = [cos(t+pi/3) sin(t+pi/3) ones(3,1)];
                    dirs = idgeometryexplorer.normalizeRows([lowerFace;upperFace]); label = 'Trigonal prismatic, CN = 6';
                case 'pentagonalbipyramidal'
                    t = (0:4)'*2*pi/5; dirs = [cos(t) sin(t) zeros(5,1);0 0 1;0 0 -1]; label = 'Pentagonal bipyramidal, CN = 7';
                case 'squareantiprismatic'
                    t = (0:3)'*pi/2; bottomFace = [cos(t) sin(t) -ones(4,1)]; topFace = [cos(t+pi/4) sin(t+pi/4) ones(4,1)];
                    dirs = idgeometryexplorer.normalizeRows([bottomFace;topFace]); label = 'Square antiprismatic, CN = 8';
                case 'tricappedtrigonalprismatic'
                    t = (0:2)'*2*pi/3; lowerFace = [cos(t) sin(t) -ones(3,1)]; upperFace = [cos(t+pi/3) sin(t+pi/3) ones(3,1)];
                    caps = [0 1 0;sqrt(3)/2 -1/2 0;-sqrt(3)/2 -1/2 0];
                    dirs = idgeometryexplorer.normalizeRows([lowerFace;upperFace;caps]); label = 'Tricapped trigonal prism, CN = 9';
                otherwise
                    error('Unsupported idealised geometry: %s', name);
            end
        end
    end

    methods(Static,Access=private)
        function E = addElements(E,row,symbols,cols,Zs)
            assert(numel(symbols)==numel(cols) && numel(symbols)==numel(Zs),'Element data dimensions differ.');
            for k = 1:numel(symbols)
                E(end+1) = struct('Z',Zs(k),'symbol',symbols{k},'row',row,'col',cols(k),'block','','series',''); %#ok<AGROW>
            end
        end
        function block = blockOf(e)
            if e.row >= 8, block = 'f'; elseif e.col <= 2, block = 's'; elseif e.col >= 13, block = 'p'; else, block = 'd'; end
            if strcmp(e.symbol,'He'), block = 's'; end
        end
        function series = seriesOf(e)
            if e.row == 8, series = 'lanthanide'; elseif e.row == 9, series = 'actinide'; elseif strcmp(e.block,'d'), series = 'transition metal'; else, series = 'main group'; end
        end
        function Z = elementZ(E,symbol)
            i = find(strcmp({E.symbol},symbol),1); assert(~isempty(i),'Element %s is absent.',symbol); Z = E(i).Z;
        end
        function c = blockColor(block)
            switch block
                case 's', c = [.98 .80 .42];
                case 'p', c = [.98 .52 .45];
                case 'd', c = [.63 .62 .86];
                case 'f', c = [.86 .90 .42];
                otherwise, c = [.85 .85 .85];
            end
        end
        function V = normalizeRows(V)
            V = V ./ vecnorm(V,2,2);
        end
    end
end
