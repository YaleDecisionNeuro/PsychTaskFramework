function [ trialData ] = SODM_showChoice(trialData, blockConfig, phaseConfig)
% SODM_SHOWCHOICE Executes the SODM trial phase of showing the task choice to
%   the subject and collecting their response. Choice values are derived
%   from `trialData` and, if need be, `blockConfig`.

windowPtr = blockConfig.device.windowPtr;

% Draw the background
if isfield(blockConfig.task.fnHandles, 'bgrDrawFn') && ...
    isa(blockConfig.task.fnHandles.bgrDrawFn, 'function_handle')
  blockConfig.task.fnHandles.bgrDrawFn(blockConfig);
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
  % Try to obtain response while the task is ongoing
  trialData = timeAndRecordTask(trialData, blockConfig);
end
end

% Local function with timing responsibility
function trialData = timeAndRecordTask(trialData, blockConfig)
  %% Record choice & assign feedback color
  [keyisdown, trialData.rt, keycode, trialData.rt_ci] = ...
    waitForKey({'1!', '2@'}, blockConfig.trial.legacyPhases.showChoice.duration);
  if keyisdown && keycode(KbName('1!'))
      trialData.choice = 1;
  elseif keyisdown && keycode(KbName('2@'))
      trialData.choice = 2;
  else % non-press
      trialData.choice = 0;
      trialData.rt = NaN;
  end
  [ refSide, ~ ] = getReferenceSideAndValue(trialData, blockConfig);
  trialData.choseLottery = keyToChoice(trialData.choice, refSide);
end
