function [ trialData ] = UVRA_showChoice(trialData, blockSettings, phaseSettings)
% UVRA_SHOWCHOICE Executes the monetary R&A trial stage of showing the task choice
%   to the participant. Choice values are derived from `trialData` and,
%   if need be, `blockSettings`. They are displayed vertically and expect a
%   participant response.

windowPtr = blockSettings.device.windowPtr;

% Draw the background
if isfield(blockSettings.task.fnHandles, 'bgrDrawFn') && ...
    isa(blockSettings.task.fnHandles.bgrDrawFn, 'function_handle')
  blockSettings.task.fnHandles.bgrDrawFn(blockSettings);
end

% Determine off-centering
if blockSettings.runSetup.refSide == 2
  blockSettings.objects.lottery.offCenterByPx = -1 * blockSettings.objects.lottery.offCenterByPx;
end

% Draw the lottery box
drawLotto(trialData, blockSettings);

% Draw the reference value
blockSettings.task.fnHandles.referenceDrawFn(blockSettings, trialData);

% Show all drawn objects and retrieve the timestamp of display
[~, ~, phaseSettings.startTimestamp, ~, ~] = Screen('flip', windowPtr);
trialData.choiceStartTime = datevec(now);
trialData.showChoiceStartTS = phaseSettings.startTimestamp;

%% Handle the display properties & book-keeping
if exist('phaseSettings', 'var') && isfield(phaseSettings, 'action') ...
    && isa(phaseSettings.action, 'function_handle')
  % Allow the execution of a actionFnHandle if passed
  trialData = phaseSettings.action(trialData, blockSettings, phaseSettings);
else
  % Deprecated: Display choice for blockSettings.trial.legacyPhases.showChoice.duration
  trialData = timeAndRecordTask(trialData, blockSettings);
end
end

% Local function with timing responsibility
function trialData = timeAndRecordTask(trialData, blockSettings)
  %% Record choice & assign feedback color
  [keyisdown, trialData.rt, keycode, trialData.rt_ci] = ...
    waitForKey({'UpArrow', 'DownArrow'}, blockSettings.trial.legacyPhases.showChoice.duration);
  if keyisdown && keycode(KbName('UpArrow'))
      trialData.choice = 1;
  elseif keyisdown && keycode(KbName('DownArrow'))
      trialData.choice = 2;
  else % non-press
      trialData.choice = 0;
      trialData.rt = NaN;
  end
  trialData.choseLottery = keyToChoice(trialData.choice, ...
    blockSettings.runSetup.refSide);
end
