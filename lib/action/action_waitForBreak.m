function [ trialData ] = action_waitForBreak(trialData, blockConfig, phaseConfig)
[ startTimestamp, found ] = findPTBTimestamp(trialData, phaseConfig);
if ~found
  warning('In phase %s, phaseConfig.startTimestamp was not provided.', ...
    phaseConfig.name)
end
waitForKey(blockConfig.device.breakKeys, phaseConfig.duration - (GetSecs() - startTimestamp));
end
