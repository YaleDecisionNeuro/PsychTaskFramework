function drawITI(trialData, blockConfig)
% Draws the inactivity symbol (by default, white oval) between trials.
%
% Args:
%   trialData: The participant data from a trial (unused)
%   blockConfig: The block settings
%
% Returns:
%   Like all draw functions, it has no return.
%
% Todo: 
%   Nigh-duplicate code with drawResponsePrompt. Factor out the general
%   "draw an object in the center when provided the center and
%   blockConfig.draw.(object)".

windowPtr = blockConfig.device.windowPtr;
W = blockConfig.device.windowWidth; % width
H = blockConfig.device.windowHeight; % height
center = [W / 2, H / 2];
Screen('FillOval', windowPtr, blockConfig.draw.intertrial.color, ...
  centerRectDims(center, blockConfig.draw.intertrial.dims));
end
