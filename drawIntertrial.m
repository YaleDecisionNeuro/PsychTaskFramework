function [ trialData ] = drawIntertrial(trialData, trialSettings, blockSettings, callback)
W = blockSettings.device.screenDims(3); % width
H = blockSettings.device.screenDims(4); % height
windowPtr = blockSettings.device.windowPtr;

center = [W / 2, H / 2];
Screen('FillOval', windowPtr, blockSettings.intertrial.color, ...
  centerRectDims(center, blockSettings.intertrial.dims));
Screen('flip', windowPtr);
trialData = timeIntertrial(trialData, trialSettings, blockSettings);
if exist('callback', 'var') && isHandle(callback)
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
