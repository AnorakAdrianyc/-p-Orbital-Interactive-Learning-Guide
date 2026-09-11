function prepareGraphics()
% PREPAREGRAPHICS Headless-friendly defaults for MATLAB and Octave SVG export.

if exist('OCTAVE_VERSION', 'builtin') == 5
    try
        graphics_toolkit('gnuplot');
    catch
    end
    try
        set(0, 'defaultfigurevisible', 'off');
    catch
    end
end
end
