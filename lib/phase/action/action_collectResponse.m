function [ trialData ] = action_collectResponse(trialData, blockSettings, phaseSettings)
% For duration specified in phaseSettings.duration, wait for a keypress specified
%   in phaseSettings.responseKeys
% TODO: Establish phaseSettings?
keys = blockSettings.device.choiceKeys;

[keyisdown, trialData.rt, keycode, trialData.rt_ci] = ...
  waitForKey(keys, phaseSettings.duration);
if keyisdown && keycode(KbName(keys{1}))
  trialData.choice = 1;
elseif keyisdown && keycode(KbName(keys{2}))
  trialData.choice = 2;
else % non-press
  trialData.choice = 0;
  trialData.rt = NaN;
end
trialData.choseLottery = keyToChoice(trialData.choice, ...
  blockSettings.perUser.refSide);
end
