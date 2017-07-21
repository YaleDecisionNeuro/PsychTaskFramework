function [ trialData ] = action_waitForBreak(trialData, blockConfig, phaseConfig)
% Phase action that waits for a defined duration for a defined break key.
%
% Duration is defined under phaseConfig.duration and the break key is
%   defined under blockConfig.device.breakKeys.
%
% Args:
%   trialData: The participant data from a trial
%   blockConfig: The block settings
%   phaseConfig: The phase settings
%
% Returns:
%   trialData: The participant data from a trial.
%
[ startTimestamp, found ] = findPTBTimestamp(trialData, phaseConfig);
if ~found
  warning('In phase %s, phaseConfig.startTimestamp was not provided.', ...
    phaseConfig.name)
end
waitForKey(blockConfig.device.breakKeys, phaseConfig.duration - (GetSecs() - startTimestamp));
end
