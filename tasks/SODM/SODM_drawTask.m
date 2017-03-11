function [ trialData ] = SODM_drawTask(trialData, blockSettings, callback)
% SODM_DRAWTASK Executes the SODM trial stage of showing the task choice to
%   the participant. Choice values are derived from `trialData` and,
%   if need be, `blockSettings`.

windowPtr = blockSettings.device.windowPtr;

% Draw the background
if isfield(blockSettings.game, 'bgrDrawFn') && ...
    isa(blockSettings.game.bgrDrawFn, 'function_handle')
  blockSettings.game.bgrDrawFn(blockSettings);
end

% Draw the lottery box
drawLotto(trialData, blockSettings);

% Draw the reference value
blockSettings.game.referenceDrawFn(blockSettings, trialData);

% Show all drawn objects
Screen('flip', windowPtr);

%% Handle the display properties & book-keeping
trialData.choiceStartTime = datevec(now);
trialData = timeAndRecordTask(trialData, blockSettings);

% Allow the execution of a callback if passed
if exist('callback', 'var') && isa(callback, 'function_handle')
  trialData = callback(trialData, blockSettings);
end
end

% Local function with timing responsibility
function trialData = timeAndRecordTask(trialData, blockSettings)
  %% Record choice & assign feedback color
  [keyisdown, trialData.rt, keycode, trialData.rt_ci] = ...
    waitForKey({'1!', '2@'}, blockSettings.game.durations.choice);
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
