function prepareGraphics()
% PREPAREGRAPHICS Headless-friendly defaults for MATLAB and Octave SVG export.

if exist('OCTAVE_VERSION', 'builtin') == 5
    if isempty(getenv('QT_QPA_PLATFORM'))
        setenv('QT_QPA_PLATFORM', 'offscreen');
    end
    tk = {};
    try
        tk = available_graphics_toolkits();
    catch
        tk = {};
    end
    if any(strcmp(tk, 'qt'))
        try
            graphics_toolkit('qt');
        catch
        end
    elseif any(strcmp(tk, 'gnuplot'))
        try
            graphics_toolkit('gnuplot');
        catch
        end
    end
    try
        set(0, 'defaultfigurevisible', 'off');
    catch
    end
end
end
