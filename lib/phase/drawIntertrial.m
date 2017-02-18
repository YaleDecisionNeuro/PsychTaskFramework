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

% Do we need the entire trial to last a constant amount of time? If so:
% (1) the `elapsedTime` initial reference point is `trialStartTime` rather than
%     `.ITIStartTime`
% (2) the endtime is the sum of `s.game.durations` rather than `.durations.ITIs`
if blockSettings.game.constantTrialDuration
  startReference = trialData.trialStartTime;
  endReference = blockSettings.game.durations.choice + ...
    blockSettings.game.durations.response + ...
    blockSettings.game.durations.feedback + ...
    trialSettings.ITIs;
else
  startReference = trialData.ITIStartTime;
  endReference = trialSettings.ITIs;
end

elapsedTime = etime(datevec(now), startReference);
while elapsedTime < endReference
  elapsedTime = etime(datevec(now), startReference);
end
end
