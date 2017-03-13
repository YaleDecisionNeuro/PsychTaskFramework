function [ trialData ] = action_display(trialData, blockSettings, phaseSettings)
% For duration specified in phaseSettings.duration, maintain the phase
if isfield(phaseSettings, 'startTimestamp') % other locations?
  startTimestamp = phaseSettings.startTimestamp; % grab from Screen('Flip')?
else
  startTimestamp = GetSecs();
  warning('In phase %s, phaseSettings.startTimestamp was not provided.', ...
    phaseSettings.name)
end
endTimestamp = startTimestamp + phaseSettings.duration;

while GetSecs() < endTimestamp
  WaitSecs(blockSettings.device.sleepIncrements);
end
end
