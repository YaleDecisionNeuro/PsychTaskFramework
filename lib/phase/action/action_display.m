function [ trialData ] = action_display(trialData, blockSettings, phaseSettings)
% For duration specified in phaseSettings.duration, maintain the phase
[ startTimestamp, found ] = findPTBTimestamp(trialData, phaseSettings);
if ~found
  warning('In phase %s, phaseSettings.startTimestamp was not provided.', ...
    phaseSettings.name)
end
endTimestamp = startTimestamp + phaseSettings.duration;

while GetSecs() < endTimestamp
  WaitSecs(blockSettings.device.sleepIncrements);
end
end
