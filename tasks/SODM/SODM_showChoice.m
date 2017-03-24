function [ trialData ] = SODM_showChoice(trialData, blockSettings, phaseSettings)
% SODM_SHOWCHOICE Executes the SODM trial phase of showing the task choice to
%   the participant and collecting their response. Choice values are derived
%   from `trialData` and, if need be, `blockSettings`.

windowPtr = blockSettings.device.windowPtr;

% Draw the background
if isfield(blockSettings.task.fnHandles, 'bgrDrawFn') && ...
    isa(blockSettings.task.fnHandles.bgrDrawFn, 'function_handle')
  blockSettings.task.fnHandles.bgrDrawFn(blockSettings);
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
  % Try to obtain response while the task is ongoing
  trialData = timeAndRecordTask(trialData, blockSettings);
end
end

% Local function with timing responsibility
function trialData = timeAndRecordTask(trialData, blockSettings)
  %% Record choice & assign feedback color
  [keyisdown, trialData.rt, keycode, trialData.rt_ci] = ...
    waitForKey({'1!', '2@'}, blockSettings.trial.legacyPhases.showChoice.duration);
  if keyisdown && keycode(KbName('1!'))
      trialData.choice = 1;
  elseif keyisdown && keycode(KbName('2@'))
      trialData.choice = 2;
  else % non-press
      trialData.choice = 0;
      trialData.rt = NaN;
  end
  trialData.choseLottery = keyToChoice(trialData.choice, ...
    blockSettings.runSetup.refSide);
end
