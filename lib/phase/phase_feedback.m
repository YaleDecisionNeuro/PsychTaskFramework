function [ trialData ] = phase_feedback(trialData, blockSettings, phaseSettings)
% PHASE_FEEDBACK Based on the value in `trialData.choice`, draws the feedback
%   that confirms to the player which option they chose (or whether they chose
%   at all) and displays it for `blockSettings.game.durations.feedback`. Can be
%   re-used for tasks that offer two options in a choice.

windowPtr = blockSettings.device.windowPtr;
drawFeedback(trialData, blockSettings);
[~, ~, phaseSettings.startTimestamp, ~, ~] = Screen('flip', windowPtr);
trialData.feedbackStartTime = datevec(now);
% TODO: Save also to trialData.feedbackStart / trialData.feedbackStartTS?

%% Handle the display properties & book-keeping
if exist('phaseSettings', 'var') && isfield(phaseSettings, 'action') ...
    && isa(phaseSettings.action, 'function_handle')
  % Allow the execution of a actionFnHandle if passed
  trialData = phaseSettings.action(trialData, blockSettings, phaseSettings);
else
  % Deprecated: Display feedback for blockSettings.game.durations.feedback
  trialData = timeFeedback(trialData, blockSettings);
end
end

% Old behavior -- let the function automagically find the duration to have
% Deprecated: remains for backwards compatibility
function trialData = timeFeedback(trialData, blockSettings)
  elapsedTime = etime(datevec(now), trialData.feedbackStartTime);
  while elapsedTime < blockSettings.game.durations.feedback
    elapsedTime = etime(datevec(now), trialData.feedbackStartTime);
  end
end
