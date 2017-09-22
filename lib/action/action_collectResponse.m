function [ trialData ] = action_collectResponse(trialData, blockConfig, phaseConfig)
% Phase action to record the participant's response.
%
% For duration specified in phaseConfig.duration, waits for one of the
% keypresses specified in blockConfig.device.choiceKeys.
%
% Warning:
%   Currently, the function is R&A-specific: it will only expect the first two
%   keys, and it will recode the choice to choseLottery via keyToChoice.
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
