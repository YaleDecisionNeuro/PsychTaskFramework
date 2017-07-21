function [ trialData ] = phase_ITI(trialData, blockConfig, phaseConfig)
% Displays the inactivity symbol in between trials. Its duration
%   is based on the value in `trialData.ITIs`.
%
% Args: 
%   trialData: The participant data from a trial
%   blockConfig: The block settings
%   phaseConfig: The phase settings
% 
% Returns:
%   trialData: The participant data from a trial.
%
% TODO: Modular phase has no smart way of determining what the duration
%   should be if it is constant. It relies on a duration fields in
%   blockConfig.trial.legacyPhases.{X} enumeration. Possible solution:
%   trialData.trialDuration, which checks for
%   blockConfig.task.constantBlockDuration to see what duration to do.
%   (Alternative: if isnan(phaseConfig.duration), need to compute it.)

windowPtr = blockConfig.device.windowPtr;
drawITI(trialData, blockConfig);
[~, ~, phaseConfig.startTimestamp, ~, ~] = Screen('flip', windowPtr);
trialData.ITIStartTime = datevec(now);
trialData.ITIStartTS = phaseConfig.startTimestamp;

if exist('phaseConfig', 'var') && isfield(phaseConfig, 'action') ...
    && isa(phaseConfig.action, 'function_handle')
  trialData = phaseConfig.action(trialData, blockConfig, phaseConfig);
else
  trialData = timeIntertrial(trialData, blockConfig);
end
end

% Unlike other in-phase timing function, timeIntertrial is not yet deprecated,
% as it implements the mission critical blockConfig.task.constantBlockDuration
% switch.
function trialData = timeIntertrial(trialData, blockConfig)
% Setting the trial to last a constant amount of time. 
%
% Do we need the entire trial to last a constant amount of time? If so:
% (1) the `elapsedTime` initial reference point is `trialStartTime` rather than
%     `.ITIStartTime`
% (2) the endtime is the sum of `s.trial.legacyPhases.X.duration` rather than `.legacyPhases.intertrial.duration`
%
% Args:
%   trialData: The participant data from a trial
%   blockConfig: The block settings
% 
% Returns:
%   trialData: The participant data from a trial.

if blockConfig.task.constantBlockDuration
  startReference = trialData.trialStartTime;
  endReference = blockConfig.trial.legacyPhases.showChoice.duration + ...
    blockConfig.trial.legacyPhases.response.duration + ...
    blockConfig.trial.legacyPhases.feedback.duration + ...
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
