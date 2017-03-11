function [ trialData ] = phase_showChoice(trialData, trialSettings, blockSettings, actionFnHandle)
% MDM_DRAWTASK Executes the MDM trial stage of showing the task choice to
%   the participant. Choice values are derived from `trialData` and,
%   if need be, `blockSettings`.

windowPtr = blockSettings.device.windowPtr;

% Draw the background
if isfield(blockSettings.game, 'bgrDrawFn') && ...
    isa(blockSettings.game.bgrDrawFn, 'function_handle')
  blockSettings.game.bgrDrawFn(blockSettings);
end

% Draw the lottery box
drawLotto(trialSettings, blockSettings);

% Draw the reference value
blockSettings.game.referenceDrawFn(blockSettings, trialSettings);

% Show all drawn objects and retrieve the timestamp of display
[~, ~, trialData.choiceDisplayTimestamp, ~, ~] = Screen('flip', windowPtr);

%% Handle the display properties & book-keeping
trialData = timeAndRecordTask(trialData, trialData, blockSettings);

% Allow the execution of a actionFnHandle if passed
if exist('actionFnHandle', 'var') && isa(actionFnHandle, 'function_handle')
  trialData = actionFnHandle(trialData, trialData, blockSettings);
end
end

% Local function with timing responsibility
function trialData = timeAndRecordTask(trialData, trialSettings, blockSettings)
  % Extract to local variables now because struct field access costs time
  trialStart = trialData.trialStartTime; % FIXME: Relies on runTrial to set it
  trialDur = blockSettings.game.durations.choice;

  elapsedTime = etime(datevec(now), trialStart);
  while elapsedTime < trialDur
      elapsedTime = etime(datevec(now), trialStart);
  end
end
