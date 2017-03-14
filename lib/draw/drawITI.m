function drawITI(trialData, blockSettings)
% DRAWITI Draws the inactivity symbol (by default, white oval) between trials.
%
% FIXME: Nigh-duplicate code with drawResponsePrompt. Factor out the general
% "draw an object in the center when provided the center and
% blockSettings.objects.(object)".

windowPtr = blockSettings.device.windowPtr;
W = blockSettings.device.windowWidth; % width
H = blockSettings.device.windowHeight; % height
center = [W / 2, H / 2];
Screen('FillOval', windowPtr, blockSettings.objects.intertrial.color, ...
  centerRectDims(center, blockSettings.objects.intertrial.dims));
end
