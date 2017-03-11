function [ trialData ] = MDM_drawTask(trialData, trialSettings, blockSettings, callback)
% MDM_DRAWTASK Executes the MDM trial stage of showing the task choice to
%   the participant. Choice values are derived from `trialSettings` and,
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

% Show all drawn objects
Screen('flip', windowPtr);

%% Handle the display properties & book-keeping
trialData = timeAndRecordTask(trialData, trialSettings, blockSettings);

% Allow the execution of a callback if passed
if exist('callback', 'var') && isa(callback, 'function_handle')
  trialData = callback(trialData, trialSettings, blockSettings);
end
end

% Local function with timing responsibility
function trialData = timeAndRecordTask(trialData, trialSettings, blockSettings)
  % Extract to local variables now because struct field access costs time
  trialStart = trialData.trialStartTime;
  trialDur = blockSettings.game.durations.choice;

  elapsedTime = etime(datevec(now), trialStart);
  while elapsedTime < trialDur
      elapsedTime = etime(datevec(now), trialStart);
  end
end
