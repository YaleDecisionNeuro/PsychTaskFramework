function [ trialData ] = action_waitForBreak(trialData, phaseSettings, blockSettings)
  waitForKey(blockSettings.device.breakKeys, phaseSettings.duration);
end
