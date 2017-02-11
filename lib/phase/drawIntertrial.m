function [ trialData ] = drawIntertrial(trialData, trialSettings, blockSettings, callback)
% DRAWINTERTRIAL Displays the inactivity symbol in between trials. Its duration
%   is based on the value in `trialSettings.ITIs`.

W = blockSettings.device.screenDims(3); % width
H = blockSettings.device.screenDims(4); % height
windowPtr = blockSettings.device.windowPtr;

center = [W / 2, H / 2];
Screen('FillOval', windowPtr, blockSettings.objects.intertrial.color, ...
  centerRectDims(center, blockSettings.objects.intertrial.dims));
Screen('flip', windowPtr);
trialData = timeIntertrial(trialData, trialSettings, blockSettings);
if exist('callback', 'var') && isa(callback, 'function_handle')
  trialData = callback(trialData, trialSettings, blockSettings);
end
end

% Local function with timing responsibility
function trialData = timeIntertrial(trialData, trialSettings, blockSettings)
trialData.ITIStartTime = datevec(now);

elapsedTime = etime(datevec(now), trialData.trialStartTime);

totalTrialTime = blockSettings.game.durations.choice + ...
  blockSettings.game.durations.response + ...
  blockSettings.game.durations.feedback + ...
  trialSettings.ITIs;
while elapsedTime < totalTrialTime
    elapsedTime = etime(datevec(now), trialData.trialStartTime);
end
end
