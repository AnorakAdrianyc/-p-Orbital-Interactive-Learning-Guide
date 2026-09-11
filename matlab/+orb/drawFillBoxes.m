function drawFillBoxes(ax, rows)
% DRAWFILLBOXES Aufbau-style orbital boxes with up/down arrows.
%
% rows is a cell array of structs (or parallel cell arrays packed as
% {label, occupations} where occupations is a vector with entries
%   0 empty, 1 one up-electron, 2 paired, -1 one down-electron.
%
% Convenience form:
%   rows = { {'3s', [2]}, {'3p', [1 1 0]} };

if nargin < 1 || isempty(ax)
    ax = gca;
end
cla(ax);
hold(ax, 'on');
axis(ax, 'off');
set(ax, 'YDir', 'reverse');
nR = numel(rows);
boxW = 0.85;
boxH = 0.95;
gap = 0.18;
y0 = 0.3;
for i = 1:nR
    row = rows{i};
    lab = row{1};
    occ = row{2};
    nB = numel(occ);
    y = y0 + (i - 1) * 1.45;
    text(ax, -0.15, y + boxH / 2, lab, 'HorizontalAlignment', 'right', ...
        'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
    for j = 1:nB
        x = (j - 1) * (boxW + gap);
        rectangle(ax, 'Position', [x y boxW boxH], ...
            'EdgeColor', [0.15 0.15 0.15], 'LineWidth', 1.4, ...
            'FaceColor', [1 1 1]);
        drawArrows(ax, x, y, boxW, boxH, occ(j));
    end
end
axis(ax, [-1.8, 12, -0.2, y0 + nR * 1.45]);
axis(ax, 'equal');
end

function drawArrows(ax, x, y, w, h, occ)
cx = x + w / 2;
if occ == 0
    return;
end
if occ == 2
    text(ax, cx - 0.16, y + h * 0.52, '\uparrow', ...
        'FontSize', 16, 'HorizontalAlignment', 'center', 'Color', [0.10 0.25 0.55]);
    text(ax, cx + 0.16, y + h * 0.52, '\downarrow', ...
        'FontSize', 16, 'HorizontalAlignment', 'center', 'Color', [0.70 0.15 0.12]);
elseif occ == 1
    text(ax, cx, y + h * 0.52, '\uparrow', ...
        'FontSize', 18, 'HorizontalAlignment', 'center', 'Color', [0.10 0.25 0.55]);
elseif occ == -1
    text(ax, cx, y + h * 0.52, '\downarrow', ...
        'FontSize', 18, 'HorizontalAlignment', 'center', 'Color', [0.70 0.15 0.12]);
end
end
