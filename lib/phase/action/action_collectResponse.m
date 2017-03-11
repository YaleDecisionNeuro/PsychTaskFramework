function [ trialData ] = action_collectResponse(trialData, trialSettings, phaseSettings, blockSettings)
% For duration specified in phaseSettings.duration, wait for a keypress specified
%   in phaseSettings.responseKeys
% TODO: Make responseKeys variable
% TODO: Establish phaseSettings?

[keyisdown, trialData.rt, keycode, trialData.rt_ci] = ...
  waitForKey({'1!', '2@'}, phaseSettings.duration);
if keyisdown && keycode(KbName('1!'))
  trialData.choice = 1;
elseif keyisdown && keycode(KbName('2@'))
  trialData.choice = 2;
else % non-press
  trialData.choice = 0;
  trialData.rt = NaN;
end
trialData.choseLottery = keyToChoice(trialData.choice, ...
  blockSettings.perUser.refSide);
end
