function trialData = runRATrial(trialData, blockConfig)
% Workhorse function to display all typical phases of an risk-and-ambiguity trial. 
%
% In turn, it displays the task-specific choice
%   options, response prompt, response input feedback, and the intertrial
%   period. It displays them using function handles set in
%   `blockConfig.trial.legacyPhases`.
%
% Args:
%   trialData: Information gathered from a trial
%   blockConfig: The block settings
%
% Returns:
%   trialData: Information gathered from a trial.

% Record the properties of this trial to trialData
trialData.trialStartTime = datevec(now);

% Create convenience variables
% TODO: Should this attempt to run in non-legacy situations?
s = blockConfig.trial.legacyPhases;
showChoicePhase = s.showChoice.phaseScript;
responsePhase = s.response.phaseScript;
feedbackPhase = s.feedback.phaseScript;
intertrialPhase = s.intertrial.phaseScript;

% 1. Display the choice for the trial
if isfield(s.showChoice, 'action') && isFunction(s.showChoice.action)
  showChoiceConf = phaseConfig('showChoice', 'duration', s.showChoice.duration, ...
    'phaseScript', showChoicePhase, 'action', s.showChoice.action);
  trialData = runPhase(trialData, blockConfig, showChoiceConf);
else
  trialData = showChoicePhase(trialData, blockConfig);
end

% 2. If defined, display the response-collecting phase
if isFunction(responsePhase)
  if isfield(s.response, 'action') && isFunction(s.response.action)
    responseConf = phaseConfig('response', 'duration', s.response.duration, ...
      'phaseScript', responsePhase, 'action', s.response.action);
    trialData = runPhase(trialData, blockConfig, responseConf);
  else
    trialData = responsePhase(trialData, blockConfig);
  end
end

% Print choice to stdout
disp(choiceReport(trialData));

% 3. If defined, display the feedback phase
if isFunction(feedbackPhase)
  if isfield(s.feedback, 'action') && isFunction(s.feedback.action)
    feedbackConf = phaseConfig('feedback', 'duration', s.feedback.duration, ...
      'phaseScript', feedbackPhase, 'action', s.feedback.action);
    trialData = runPhase(trialData, blockConfig, feedbackConf);
  else
    trialData = feedbackPhase(trialData, blockConfig);
  end
end

% 4. If defined, display the intertrial phase
if isFunction(intertrialPhase)
  if isfield(s.intertrial, 'action') && isFunction(s.intertrial.action)
    intertrialConf = phaseConfig('intertrial', 'duration', s.intertrial.duration, ...
      'phaseScript', intertrialPhase, 'action', s.intertrial.action);
    trialData = runPhase(trialData, blockConfig, intertrialConf);
  else
    trialData = intertrialPhase(trialData, blockConfig);
  end
end

trialData.trialEndTime = datevec(now);
end
