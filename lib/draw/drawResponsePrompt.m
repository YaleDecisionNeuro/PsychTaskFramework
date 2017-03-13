function drawResponsePrompt(trialData, blockSettings)
% DRAWRESPONSEPROMPT Draws the response prompt symbol (by default, green oval).
%
% FIXME: Nigh-duplicate code with drawITI. Factor out the general "draw an
% object in the center when provided the center and
% blockSettings.objects.(object)".

windowPtr = blockSettings.device.windowPtr;
W = blockSettings.device.windowWidth; % width
H = blockSettings.device.windowHeight; % height
center = [W / 2, H / 2];
Screen('FillOval', windowPtr, blockSettings.objects.prompt.color, ...
  centerRectDims(center, blockSettings.objects.prompt.dims));
end
