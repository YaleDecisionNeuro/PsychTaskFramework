function [ trialData ] = UVRA_showChoice(trialData, blockConfig, phaseConfig)
% UVRA_SHOWCHOICE Executes the monetary R&A trial stage of showing the task choice
%   to the subject. Choice values are derived from `trialData` and,
%   if need be, `blockConfig`. They are displayed vertically and expect a
%   subject response.

windowPtr = blockConfig.device.windowPtr;

% Draw the background
if isfield(blockConfig.task.fnHandles, 'bgrDrawFn') && ...
    isa(blockConfig.task.fnHandles.bgrDrawFn, 'function_handle')
  blockConfig.task.fnHandles.bgrDrawFn(blockConfig);
end

% Determine off-centering
if blockConfig.runSetup.refSide == 2
  blockConfig.objects.lottery.offCenterByPx = -1 * blockConfig.objects.lottery.offCenterByPx;
end

% Draw the lottery box
drawLotto(trialData, blockConfig);

% Draw the reference value
blockConfig.task.fnHandles.referenceDrawFn(blockConfig, trialData);

% Show all drawn objects and retrieve the timestamp of display
[~, ~, phaseConfig.startTimestamp, ~, ~] = Screen('flip', windowPtr);
trialData.choiceStartTime = datevec(now);
trialData.showChoiceStartTS = phaseConfig.startTimestamp;

%% Handle the display properties & book-keeping
if exist('phaseConfig', 'var') && isfield(phaseConfig, 'action') ...
    && isa(phaseConfig.action, 'function_handle')
  % Allow the execution of a actionFnHandle if passed
  trialData = phaseConfig.action(trialData, blockConfig, phaseConfig);
else
  % Deprecated: Display choice for blockConfig.trial.legacyPhases.showChoice.duration
  trialData = timeAndRecordTask(trialData, blockConfig);
end
end

% Local function with timing responsibility
function trialData = timeAndRecordTask(trialData, blockConfig)
  %% Record choice & assign feedback color
  [keyisdown, trialData.rt, keycode, trialData.rt_ci] = ...
    waitForKey({'UpArrow', 'DownArrow'}, blockConfig.trial.legacyPhases.showChoice.duration);
  if keyisdown && keycode(KbName('UpArrow'))
      trialData.choice = 1;
  elseif keyisdown && keycode(KbName('DownArrow'))
      trialData.choice = 2;
  else % non-press
      trialData.choice = 0;
      trialData.rt = NaN;
  end
  trialData.choseLottery = keyToChoice(trialData.choice, ...
    blockConfig.runSetup.refSide);
end
