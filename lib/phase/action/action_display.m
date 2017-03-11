function [ trialData ] = action_display(trialData, trialSettings, phaseSettings, blockSettings)
% For duration specified in phaseSettings.duration, maintain the phase
startTimestamp = phaseSettings.startTimestamp; % grab from Screen('Flip')?
endTimestamp = startTimestamp + phaseSettings.duration;

while GetSecs() < endTimestamp
  WaitSecs(blockSettings.device.sleepIncrements);
end
end
