function [ trialData ] = action_display(trialData, blockConfig, phaseConfig)
% Phase action to simply display phase content without any interaction.
%
% Duration is specified in phaseConfig.duration.
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
endTimestamp = startTimestamp + phaseConfig.duration;

while GetSecs() < endTimestamp
  WaitSecs(blockConfig.device.sleepIncrements);
end
end
