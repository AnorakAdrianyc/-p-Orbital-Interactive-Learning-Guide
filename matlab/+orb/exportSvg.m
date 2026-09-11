function exportSvg(fig, filePath, widthPx, heightPx)
% EXPORTSVG Write a figure to SVG (vector when the renderer allows).
%
% Uses exportgraphics(..., 'ContentType','vector') on MATLAB R2025a+
% (SVG support). Falls back to print -dsvg, which is what Octave provides.
% Avoid FaceAlpha / lighting on 2-D panels so Painters can keep them vector.

if nargin < 3 || isempty(widthPx)
    widthPx = 900;
end
if nargin < 4 || isempty(heightPx)
    heightPx = 700;
end

parent = fileparts(filePath);
if ~isempty(parent) && exist(parent, 'dir') ~= 7
    mkdir(parent);
end

set(fig, 'Color', 'w');
set(fig, 'InvertHardcopy', 'on');
try
    set(fig, 'Position', [80 80 widthPx heightPx]);
catch
end
try
    set(fig, 'PaperPositionMode', 'auto');
catch
end

ok = false;
try
    exportgraphics(fig, filePath, 'ContentType', 'vector', 'BackgroundColor', 'w');
    ok = exist(filePath, 'file') == 2;
catch
    ok = false;
end
if ~ok
    try
        print(fig, filePath, '-dsvg');
        ok = exist(filePath, 'file') == 2;
    catch
        ok = false;
    end
end
if ~ok
    try
        print(fig, '-dsvg', filePath);
    catch err
        warning('exportSvg:print', 'SVG export failed for %s: %s', filePath, err.message);
    end
end
end
