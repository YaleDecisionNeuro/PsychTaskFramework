function [ trialData ] = action_collectResponse(trialData, blockConfig, phaseConfig)
% Collect participant response to lottery and record in trial data.
%
% For duration specified in phaseConfig.duration, wait for a keypress specified
%   in blockConfig.device.choiceKeys
%
% Args:
%   trialData: The participant data from a trial
%   blockConfig: The block settings
%   phaseConfig: The phase settings
%
% Returns:
%   trialData: The participant data from a trial.

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
[ refSide, ~ ] = getReferenceSideAndValue(trialData, blockConfig);
trialData.choseLottery = keyToChoice(trialData.choice, refSide);
end
