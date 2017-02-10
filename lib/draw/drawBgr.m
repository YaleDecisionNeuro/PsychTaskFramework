function [ Data ] = drawBgr(Data, settings, callback)
% DRAWBGR Draws default background and sets default drawing properties (e.g.
%   fontName and fontSize). To draw task-specific things, you can supply a
%   callback function that does them. (For instance, you can supply the
%   task-relevant drawRef function.)
%
% FIXME: Take standard arguments for `drawX`
% FIXME: Check whether `callback` is supplied and invoke it
%

if ~isfield(settings.device, 'windowPtr')
  error('Device settings contain no designated draw screen');
end

windowPtr = settings.device.windowPtr;
HideCursor(windowPtr);

Screen('FillRect', windowPtr, settings.default.bgrColor);
Screen('TextFont', windowPtr, settings.default.fontName);
Screen('TextSize', windowPtr, settings.default.fontSize);

% Uncomment if you want reference displayed at all times
% drawRef(settings, settings.perUser.refSide);
end
