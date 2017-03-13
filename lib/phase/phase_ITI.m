function [ trialData ] = phase_ITI(trialData, blockSettings, phaseSettings)
% PHASE_ITI Displays the inactivity symbol in between trials. Its duration
%   is based on the value in `trialData.ITIs`.

% TODO: Extract drawIntertrial

W = blockSettings.device.windowWidth; % width
H = blockSettings.device.windowHeight; % height
windowPtr = blockSettings.device.windowPtr;

center = [W / 2, H / 2];
Screen('FillOval', windowPtr, blockSettings.objects.intertrial.color, ...
  centerRectDims(center, blockSettings.objects.intertrial.dims));
[~, ~, phaseSettings.startTimestamp, ~, ~] = Screen('flip', windowPtr);

if exist('phaseSettings', 'var') && isfield(phaseSettings, 'action') ...
    && isa(phaseSettings.action, 'function_handle')
  trialData = phaseSettings.action(trialData, blockSettings, phaseSettings);
else
  trialData = timeIntertrial(trialData, blockSettings);
end
end

% Local function with timing responsibility
function trialData = timeIntertrial(trialData, blockSettings)
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
    trialData.ITIs;
else
  startReference = trialData.ITIStartTime;
  endReference = trialData.ITIs;
end

elapsedTime = etime(datevec(now), startReference);
while elapsedTime < endReference
  elapsedTime = etime(datevec(now), startReference);
end
end
