function silicon_indirect_band_diagram_corrected(Eg_eV)
% SILICON_INDIRECT_BAND_DIAGRAM_CORRECTED
% Qualitative E-k diagram for crystalline silicon near room temperature.
%
% Run:
%   silicon_indirect_band_diagram_corrected
%   silicon_indirect_band_diagram_corrected(1.12)
%
% Scope: schematic teaching figure, not a calculated electronic band structure.
% The valence-band maximum is at Gamma and the conduction-band minima are
% placed schematically along Delta toward X to represent Si's indirect gap.

if nargin < 1
    Eg_eV = 1.12;
end
validateattributes(Eg_eV,{'numeric'},{'scalar','real','positive','finite'});

k = linspace(-1,1,1000);       % Dimensionless schematic Gamma-X-Gamma path.
k0 = 0.84;                     % Schematic Delta valley; not fitted band data.
Ev = -1.05*k.^2;               % Ev maximum = 0 at Gamma.
Ec = Eg_eV + 1.25*(abs(k)-k0).^2;

figure('Color','w','Name','Silicon indirect band-gap schematic', ...
       'NumberTitle','off','Position',[180 130 980 660]);
ax = axes; hold(ax,'on'); box(ax,'on'); grid(ax,'on');

fill(ax,[k fliplr(k)],[Ev -2*ones(size(k))],[.70 .82 1.00], ...
    'FaceAlpha',.22,'EdgeColor','none');
fill(ax,[k fliplr(k)],[Ec 3.25*ones(size(k))],[1.00 .75 .70], ...
    'FaceAlpha',.20,'EdgeColor','none');
plot(ax,k,Ev,'Color',[.10 .30 .78],'LineWidth',2.8);
plot(ax,k,Ec,'Color',[.82 .16 .12],'LineWidth',2.8);

plot(ax,0,0,'o','MarkerSize',8,'MarkerFaceColor',[.10 .30 .78],'MarkerEdgeColor','k');
plot(ax,[k0 -k0],[Eg_eV Eg_eV],'o','MarkerSize',8, ...
    'MarkerFaceColor',[.82 .16 .12],'MarkerEdgeColor','k');

% Fundamental gap connects extrema at different crystal momenta.
plot(ax,[0 k0],[0 Eg_eV],'k--','LineWidth',1.4);
text(ax,.42,.54*Eg_eV,sprintf('E_{g,ind} = %.2f eV',Eg_eV), ...
    'FontWeight','bold','BackgroundColor','w');
quiver(ax,.045,.06,k0-.12,Eg_eV-.15,0,'Color',[.2 .2 .2], ...
    'LineWidth',2,'MaxHeadSize',.25);
text(ax,.18,.86*Eg_eV,'photon + phonon','FontWeight','bold','BackgroundColor','w');

text(ax,-.97,-.25,'Valence band','Color',[.05 .18 .55],'FontWeight','bold');
text(ax,-.97,2.30,'Conduction band','Color',[.62 .06 .04],'FontWeight','bold');
text(ax,-.14,-.25,'VB maximum at Gamma','FontWeight','bold');
text(ax,.43,Eg_eV+.25,'CB minimum along Delta toward X','FontWeight','bold');

xline(ax,0,':','Color',[.35 .35 .35]);
xticks(ax,[-1 0 1]);
xticklabels(ax,{'X','Gamma','X'});
xlabel(ax,'Crystal momentum / wave vector, k (schematic path)');
ylabel(ax,'Energy relative to valence-band maximum (eV)');
title(ax,'Crystalline silicon: schematic indirect band gap','FontWeight','bold');
xlim(ax,[-1.05 1.05]); ylim(ax,[-1.25 3.10]);

annotation('textbox',[.135 .79 .74 .10], ...
    'String',{'Schematic only: curvatures and k positions are not a numerical E(k) calculation.', ...
    'Si is indirect because the valence-band maximum and conduction-band minimum occur at different k.'}, ...
    'FitBoxToText','off','BackgroundColor','white','EdgeColor',[.55 .55 .55],'FontSize',9);

fprintf('Si schematic indirect-gap diagram created: Eg = %.3f eV.\n',Eg_eV);
end
