function trialData = RA_drawTrial(trialSettings, blockSettings)
% RA_DRAWTRIAL Displays the trial choice, obtains feedback, records it, and
%   displays everything else before the beginning of the next trial. Specific
%   to the monetary risk&ambiguity task.

% Record the properties of this trial to trialData
trialData.trialStartTime = datevec(now);

trialData = drawTask(trialData, trialSettings, blockSettings);
trialData = handleResponse(trialData, trialSettings, blockSettings);
disp(choiceReport(trialData, trialSettings));
trialData = drawFeedback(trialData, trialSettings, blockSettings);
trialData = drawIntertrial(trialData, trialSettings, blockSettings);

trialData.trialEndTime = datevec(now);
end
