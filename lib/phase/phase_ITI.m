function [ trialData ] = phase_ITI(trialData, blockSettings, phaseSettings)
% PHASE_ITI Displays the inactivity symbol in between trials. Its duration
%   is based on the value in `trialData.ITIs`.
%
% TODO: Modular phase has no smart way of determining what the duration
% should be if it is constant. It relies on a duration fields in
% blockSettings.trial.legacyPhases.{X} enumeration. Possible solution:
% trialData.trialDuration, which checks for
% blockSettings.task.constantBlockDuration to see what duration to do.
% (Alternative: if isnan(phaseSettings.duration), need to compute it.)

windowPtr = blockSettings.device.windowPtr;
drawITI(trialData, blockSettings);
[~, ~, phaseSettings.startTimestamp, ~, ~] = Screen('flip', windowPtr);
trialData.ITIStartTime = datevec(now);
trialData.ITIStartTS = phaseSettings.startTimestamp;

if exist('phaseSettings', 'var') && isfield(phaseSettings, 'action') ...
    && isa(phaseSettings.action, 'function_handle')
  trialData = phaseSettings.action(trialData, blockSettings, phaseSettings);
else
  trialData = timeIntertrial(trialData, blockSettings);
end
end

% Unlike other in-phase timing function, timeIntertrial is not yet deprecated,
% as it implements the mission critical blockSettings.task.constantBlockDuration
% switch.
function trialData = timeIntertrial(trialData, blockSettings)
% Do we need the entire trial to last a constant amount of time? If so:
% (1) the `elapsedTime` initial reference point is `trialStartTime` rather than
%     `.ITIStartTime`
% (2) the endtime is the sum of `s.trial.legacyPhases.X.duration` rather than `.legacyPhases.intertrial.duration`
if blockSettings.task.constantBlockDuration
  startReference = trialData.trialStartTime;
  endReference = blockSettings.trial.legacyPhases.showChoice.duration + ...
    blockSettings.trial.legacyPhases.response.duration + ...
    blockSettings.trial.legacyPhases.feedback.duration + ...
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
