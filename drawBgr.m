function [ Data ] = drawBgr(Data, settings, callback)
if ~isfield(settings.device, 'windowPtr')
  error('Device settings contain no designated draw screen');
end

windowPtr = settings.device.windowPtr;
HideCursor(windowPtr);

Screen('FillRect', windowPtr, settings.background.color);
Screen('TextFont', windowPtr, settings.default.fontName);
Screen('TextSize', windowPtr, settings.default.fontSize);

drawRef(settings, Data.refSide);
end
