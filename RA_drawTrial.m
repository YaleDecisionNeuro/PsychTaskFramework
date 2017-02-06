function Data = RA_drawTrial(Data, trial, settings)
% RA_DRAWTRIAL Displays the trial choice, obtains feedback, records it, and
% displays everything else before the beginning of the next trial. Specific
% to the monetary risk&ambiguity task.

Data.currTrial = trial; % FIXME: this is dumb, there must be a better way

% Record the properties of this trial to Data
Data.trialTime(trial).trialStartTime = datevec(now);

Data = drawTask(Data, settings);
Data = handleResponse(Data, settings);
% FIXME: handleResponse overwrites, rather than appends, choices. How do?
disp(choiceReport(Data, trial));
Data = drawFeedback(Data, settings);
Data = drawIntertrial(Data, settings);

Data.trialTime(trial).trialEndTime = datevec(now);
end
