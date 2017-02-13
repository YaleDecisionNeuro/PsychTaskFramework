function trialData = runTrial(trialSettings, blockSettings)
% RUNTRIAL Generalized workhorse function to display all typical phases of an
%   individual trial. In turn, it displays the task-specific choice options,
%   response prompt, response input feedback, and the intertrial period. It
%   displays them using function handles set in `blockSettings.game`.

% Record the properties of this trial to trialData
trialData.trialStartTime = datevec(now);
s = blockSettings.game;
optionsPhase = s.optionsPhaseFn;
responsePhase = s.responsePhaseFn;
feedbackPhase = s.feedbackPhaseFn;
intertrialPhase = s.intertrialPhaseFn;

trialData = optionsPhase(trialData, trialSettings, blockSettings);
trialData = responsePhase(trialData, trialSettings, blockSettings);
disp(choiceReport(trialData, trialSettings));
trialData = feedbackPhase(trialData, trialSettings, blockSettings);
trialData = intertrialPhase(trialData, trialSettings, blockSettings);

trialData.trialEndTime = datevec(now);
end
