function trialData = runRATrial(trialData, blockSettings)
% RunRATrial Workhorse function to display all typical phases of an
%   risk-and-ambiguity trial. In turn, it displays the task-specific choice
%   options, response prompt, response input feedback, and the intertrial
%   period. It displays them using function handles set in
%   `blockSettings.game`.

% Record the properties of this trial to trialData
trialData.trialStartTime = datevec(now);

% Create convenience variables
s = blockSettings.game;
showChoicePhase = s.showChoicePhaseFn;
responsePhase = s.responsePhaseFn;
feedbackPhase = s.feedbackPhaseFn;
intertrialPhase = s.intertrialPhaseFn;

% 1. Display the choice for the trial
if isfield(s, 'showChoiceActionFn') && isFunction(s.showChoiceActionFn)
  showChoiceConf = phaseConfig('showChoice', 'duration', s.durations.showChoice, ...
    'phaseScript', showChoicePhase, 'action', s.showChoiceActionFn);
  trialData = runPhase(trialData, blockSettings, showChoiceConf);
else
  trialData = showChoicePhase(trialData, blockSettings);
end

% 2. If defined, display the response-collecting phase
if isFunction(responsePhase)
  if isfield(s, 'responseActionFn') && isFunction(s.responseActionFn)
    responseConf = phaseConfig('response', 'duration', s.durations.response, ...
      'phaseScript', responsePhase, 'action', s.responseActionFn);
    trialData = runPhase(trialData, blockSettings, responseConf);
  else
    trialData = responsePhase(trialData, blockSettings);
  end
end

% Print choice to stdout
disp(choiceReport(trialData));

% 3. If defined, display the feedback phase
if isFunction(feedbackPhase)
  if isfield(s, 'feedbackActionFn') && isFunction(s.feedbackActionFn)
    feedbackConf = phaseConfig('feedback', 'duration', s.durations.feedback, ...
      'phaseScript', feedbackPhase, 'action', s.feedbackActionFn);
    trialData = runPhase(trialData, blockSettings, feedbackConf);
  else
    trialData = feedbackPhase(trialData, blockSettings);
  end
end

% 4. If defined, display the intertrial phase
if isFunction(intertrialPhase)
  if isfield(s, 'intertrialActionFn') && isFunction(s.intertrialActionFn)
    intertrialConf = phaseConfig('intertrial', 'duration', s.durations.intertrial, ...
      'phaseScript', intertrialPhase, 'action', s.intertrialActionFn);
    trialData = runPhase(trialData, blockSettings, intertrialConf);
  else
    trialData = intertrialPhase(trialData, blockSettings);
  end
end

trialData.trialEndTime = datevec(now);
end
