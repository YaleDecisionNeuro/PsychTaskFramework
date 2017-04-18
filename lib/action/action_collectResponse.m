function [ trialData ] = action_collectResponse(trialData, blockConfig, phaseConfig)
% For duration specified in phaseConfig.duration, wait for a keypress specified
%   in phaseConfig.responseKeys
[ startTimestamp, found ] = findPTBTimestamp(trialData, phaseConfig);
if ~found
  warning('In phase %s, phaseConfig.startTimestamp was not provided.', ...
    phaseConfig.name)
end

adjustedDuration = phaseConfig.duration - (GetSecs() - startTimestamp);
keys = blockConfig.device.choiceKeys;

[keyisdown, trialData.rt, keycode, trialData.rt_ci] = ...
  waitForKey(keys, adjustedDuration);
if keyisdown && keycode(KbName(keys{1}))
  trialData.choice = 1;
elseif keyisdown && keycode(KbName(keys{2}))
  trialData.choice = 2;
else % non-press
  trialData.choice = 0;
  trialData.rt = NaN;
end
trialData.choseLottery = keyToChoice(trialData.choice, ...
  blockConfig.runSetup.refSide);
end
