function [ Data ] = drawBgr(Data, settings, callback)
% DRAWBGR Draws default background + items, *and* sets default drawing
%   properties (e.g. fontName and fontSize)
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
