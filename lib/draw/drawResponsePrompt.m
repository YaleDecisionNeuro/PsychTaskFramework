function drawResponsePrompt(trialData, blockConfig)
% DRAWRESPONSEPROMPT Draws the response prompt symbol (by default, green oval).
%
% FIXME: Nigh-duplicate code with drawITI. Factor out the general "draw an
% object in the center when provided the center and
% blockConfig.objects.(object)".

windowPtr = blockConfig.device.windowPtr;
W = blockConfig.device.windowWidth; % width
H = blockConfig.device.windowHeight; % height
center = [W / 2, H / 2];
Screen('FillOval', windowPtr, blockConfig.objects.prompt.color, ...
  centerRectDims(center, blockConfig.objects.prompt.dims));
end
