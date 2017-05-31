function [ trialData ] = phase_feedback(trialData, blockConfig, phaseConfig)
% PHASE_FEEDBACK Based on the value in `trialData.choice`, draws the feedback
%   that confirms to the player which option they chose (or whether they chose
%   at all) and displays it for `blockConfig.trial.legacyPhases.feedback.duration`. Can be
%   re-used for tasks that offer two options in a choice.

windowPtr = blockConfig.device.windowPtr;
drawFeedback(trialData, blockConfig);
[~, ~, phaseConfig.startTimestamp, ~, ~] = Screen('flip', windowPtr);
trialData.feedbackStartTS = phaseConfig.startTimestamp;
trialData.feedbackStartTime = datevec(now);

%% Handle the display properties & book-keeping
if exist('phaseConfig', 'var') && isfield(phaseConfig, 'action') ...
    && isa(phaseConfig.action, 'function_handle')
  % Allow the execution of a actionFnHandle if passed
  trialData = phaseConfig.action(trialData, blockConfig, phaseConfig);
else
  % Deprecated: Display feedback for blockConfig.trial.legacyPhases.feedback.duration
  trialData = timeFeedback(trialData, blockConfig);
end
end

% Old behavior -- let the function automagically find the duration to have
% Deprecated: remains for backwards compatibility
function trialData = timeFeedback(trialData, blockConfig)
  elapsedTime = etime(datevec(now), trialData.feedbackStartTime);
  while elapsedTime < blockConfig.trial.legacyPhases.feedback.duration
    elapsedTime = etime(datevec(now), trialData.feedbackStartTime);
  end
end
