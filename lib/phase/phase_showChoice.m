function [ trialData ] = phase_showChoice(trialData, blockSettings, phaseSettings)
% PHASE_SHOWCHOICE Shows the choices defined in trialData and blockData to the
%   participant. This includes a lottery and a reference. If available, executes
%   action defined in phaseSettings.action; otherwise, waits for duration.

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

% Show all drawn objects and retrieve the timestamp of display
[~, ~, trialData.choiceDisplayTimestamp, ~, ~] = Screen('flip', windowPtr);


% Allow the execution of a actionFnHandle if passed
if exist('phaseSettings', 'var') && isfield(phaseSettings, 'action') ...
    && isa(phaseSettings.action, 'function_handle')
  trialData = phaseSettings.action(trialData, blockSettings, phaseSettings);
else
  %% Handle the display properties & book-keeping
  trialData = timeAndRecordTask(trialData, blockSettings);
end
end

% Local function with timing responsibility
function trialData = timeAndRecordTask(trialData, blockSettings)
  % Extract to local variables now because struct field access costs time
  trialStart = trialData.trialStartTime; % FIXME: Relies on runTrial to set it
  trialDur = blockSettings.game.durations.choice;

  elapsedTime = etime(datevec(now), trialStart);
  while elapsedTime < trialDur
      elapsedTime = etime(datevec(now), trialStart);
  end
end
