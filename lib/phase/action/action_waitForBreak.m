function [ trialData ] = action_waitForBreak(trialData, blockSettings, phaseSettings)
  waitForKey(blockSettings.device.breakKeys, phaseSettings.duration);
end
