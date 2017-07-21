function [ trialData ] = action_display(trialData, blockConfig, phaseConfig)
% For duration specified in phaseConfig.duration, maintain the phase.
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
endTimestamp = startTimestamp + phaseConfig.duration;

while GetSecs() < endTimestamp
  WaitSecs(blockConfig.device.sleepIncrements);
end
end
