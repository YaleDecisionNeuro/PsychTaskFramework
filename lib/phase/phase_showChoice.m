function [ trialData ] = phase_showChoice(trialData, blockConfig, phaseConfig)
% PHASE_SHOWCHOICE Shows the choices defined in trialData and blockData to the
%   subject. This includes a lottery and a reference. If available, executes
%   action defined in phaseConfig.action; otherwise, waits for duration.

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
  % Deprecated: Display choice for blockConfig.trial.legacyPhases.showChoice.duration
  trialData = timeChoice(trialData, blockConfig);
end
end

% Old behavior -- let the function automagically find the duration to have
% Deprecated: remains for backwards compatibility
function trialData = timeChoice(trialData, blockConfig)
  % Extract to local variables now because struct field access costs time
  trialStart = trialData.choiceStartTime;
  trialDur = blockConfig.trial.legacyPhases.showChoice.duration;

  elapsedTime = etime(datevec(now), trialStart);
  while elapsedTime < trialDur
      elapsedTime = etime(datevec(now), trialStart);
  end
end
