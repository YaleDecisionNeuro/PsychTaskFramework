function trialData = runTrial(trialSettings, blockSettings)
% RUNTRIAL Generalized workhorse function to display all typical phases of an
%   individual trial. In turn, it displays the task-specific choice options,
%   response prompt, response input feedback, and the intertrial period. It
%   displays them using function handles set in `blockSettings.game`.

% Record the properties of this trial to trialData
trialData.trialStartTime = datevec(now);

% Create convenience variables
s = blockSettings.game;
optionsPhase = s.optionsPhaseFn;
responsePhase = s.responsePhaseFn;
feedbackPhase = s.feedbackPhaseFn;
intertrialPhase = s.intertrialPhaseFn;

% 1. Display the choice for the trial
trialData = optionsPhase(trialData, trialSettings, blockSettings);

% 2. If defined, display the response-collecting phase
if isa(responsePhase, 'function_handle')
  trialData = responsePhase(trialData, trialSettings, blockSettings);
end

% Print choice to stdout
disp(choiceReport(trialData, trialSettings));

% 3. If defined, display the feedback phase
if isa(feedbackPhase, 'function_handle')
  trialData = feedbackPhase(trialData, trialSettings, blockSettings);
end

% 4. If defined, display the intertrial phase
if isa(intertrialPhase, 'function_handle')
  trialData = intertrialPhase(trialData, trialSettings, blockSettings);
end

trialData.trialEndTime = datevec(now);
end
