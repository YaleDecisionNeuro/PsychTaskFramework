function [ trialData ] = action_waitForBreak(trialData, blockConfig, phaseConfig)
% Phase action to wait for a break key press.
%
% For a duration specified in phaseConfig.duration, waits for the press of a
% break key defined in blockConfig.device.breakKeys.
%
% Args:
%   trialData: The participant data from a trial so far
%   blockConfig: The block settings
%   phaseConfig: The phase settings
%
% Returns:
%   trialData: Updated participant data from a trial.

[ startTimestamp, found ] = findPTBTimestamp(trialData, phaseConfig);
if ~found
  warning('In phase %s, phaseConfig.startTimestamp was not provided.', ...
    phaseConfig.name)
end
waitForKey(blockConfig.device.breakKeys, phaseConfig.duration - (GetSecs() - startTimestamp));
end
