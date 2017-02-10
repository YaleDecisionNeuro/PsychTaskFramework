function trialData = MDM_drawTrial(trialSettings, blockSettings)
% MDM_DRAWTRIAL Displays the trial choice, obtains feedback, records it, and
%   displays everything else before the beginning of the next trial. Specific
%   to the Medical Decision-Making Task.
%
% (As you can see, it is re-using most of the sub-elements from the RA task.)

% Record the properties of this trial to Data
trialData.trialStartTime = datevec(now);

trialData = MDM_drawTask(trialData, trialSettings, blockSettings);
trialData = handleResponse(trialData, trialSettings, blockSettings);
disp(choiceReport(trialData, trialSettings));
trialData = drawFeedback(trialData, trialSettings, blockSettings);
trialData = drawIntertrial(trialData, trialSettings, blockSettings);

trialData.trialEndTime = datevec(now);
end
