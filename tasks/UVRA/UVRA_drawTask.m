function [ trialData ] = UVRA_drawTask(trialData, trialSettings, blockSettings, callback)
% UVRA_DRAWTASK Executes the monetary R&A trial stage of showing the task choice
%   to the participant. Choice values are derived from `trialSettings` and,
%   if need be, `blockSettings`. They are displayed vertically and expect a
%   participant response.

windowPtr = blockSettings.device.windowPtr;

% Draw the background
if isfield(blockSettings.game, 'bgrDrawFn') && ...
    isa(blockSettings.game.bgrDrawFn, 'function_handle')
  blockSettings.game.bgrDrawFn(blockSettings);
end

% Determine off-centering
if blockSettings.perUser.refSide == 2
  blockSettings.objects.lottery.offCenterByPx = -1 * blockSettings.objects.lottery.offCenterByPx;
end

% Draw the lottery box
drawLotto(trialSettings, blockSettings);

% Draw the reference value
blockSettings.game.referenceDrawFn(blockSettings, trialSettings);

% Show all drawn objects
Screen('flip', windowPtr);

%% Handle the display properties & book-keeping
trialData.choiceStartTime = datevec(now);
trialData = timeAndRecordTask(trialData, trialSettings, blockSettings);

% Allow the execution of a callback if passed
if exist('callback', 'var') && isa(callback, 'function_handle')
  trialData = callback(trialData, trialSettings, blockSettings);
end
end

% Local function with timing responsibility
function trialData = timeAndRecordTask(trialData, trialSettings, blockSettings)
  %% Record choice & assign feedback color
  [keyisdown, trialData.rt, keycode, trialData.rt_ci] = ...
    waitForKey({'UpArrow', 'DownArrow'}, blockSettings.game.durations.choice);
  if keyisdown && keycode(KbName('UpArrow'))
      trialData.choice = 1;
  elseif keyisdown && keycode(KbName('DownArrow'))
      trialData.choice = 2;
  else % non-press
      trialData.choice = 0;
      trialData.rt = NaN;
  end
  trialData.choseLottery = keyToChoice(trialData.choice, ...
    blockSettings.perUser.refSide);
end
