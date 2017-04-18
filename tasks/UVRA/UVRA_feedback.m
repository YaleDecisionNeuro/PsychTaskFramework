function [ trialData ] = UVRA_feedback(trialData, blockConfig, callback)
% UVRA_FEEDBACK Based on the value in `trialData.choice`, it draws the feedback
%   that confirms to the player which option they chose (or whether they chose
%   at all) and displays it for `blockConfig.trial.legacyPhases.feedback.duration`. Can be
%   re-used for tasks that offer two options in a choice.
%
% UVRA_feedback differs from phase_feedback by drawing the feedback vertically.
%
% TODO: Modularize drawFeedback so that it can draw things vertically in order
%   to render this function unnecessary

W = blockConfig.device.windowWidth; % width
H = blockConfig.device.windowHeight; % height
center = [W / 2, H / 2];
windowPtr = blockConfig.device.windowPtr;

feedbackSize = blockConfig.objects.feedback.dims;
pxOffCenter = [0, 0.05 * H];

% NOTE: Use structs / element class?
button1 = centerRectDims(center, feedbackSize, -pxOffCenter);
button2 = centerRectDims(center, feedbackSize, pxOffCenter);

button1_color = blockConfig.objects.feedback.colorNoAnswer;
button2_color = blockConfig.objects.feedback.colorNoAnswer;

%% Record choice & assign feedback color
% TODO: If a function can translate choice + refSide into a lottery choice,
% this could flag stochastic dominance violations as they happen
if trialData.choice == 1
    button1_color = blockConfig.objects.feedback.colorAnswer;
elseif trialData.choice == 2
    button2_color = blockConfig.objects.feedback.colorAnswer;
end

%% Display feedback (two squares)
Screen('FillRect', windowPtr, button1_color, button1);
Screen('FillRect', windowPtr, button2_color, button2);

% Re-draw reference and note feedback length
[~, ~, phaseConfig.startTimestamp, ~, ~] = Screen('flip', windowPtr);
trialData.feedbackStartTS = phaseConfig.startTimestamp;
trialData.feedbackStartTime = datevec(now);
% TODO: Save also to trialData.feedbackStart / trialData.feedbackStartTS?

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

% Local function with timing responsibility
function trialData = timeFeedback(trialData, blockConfig)
  elapsedTime = etime(datevec(now), trialData.feedbackStartTime);
  while elapsedTime < blockConfig.trial.legacyPhases.feedback.duration
    elapsedTime = etime(datevec(now), trialData.feedbackStartTime);
  end
end
