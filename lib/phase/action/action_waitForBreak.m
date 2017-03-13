function [ trialData ] = action_waitForBreak(trialData, blockSettings, phaseSettings)
[ startTimestamp, found ] = findPTBTimestamp(trialData, phaseSettings);
if ~found
  warning('In phase %s, phaseSettings.startTimestamp was not provided.', ...
    phaseSettings.name)
end
waitForKey(blockSettings.device.breakKeys, phaseSettings.duration - (GetSecs() - startTimestamp));
end
