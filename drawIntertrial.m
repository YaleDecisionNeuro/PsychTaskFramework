function [ Data ] = drawIntertrial(Data, settings, callback)
W = settings.device.screenDims(3); % width
H = settings.device.screenDims(4); % height
windowPtr = settings.device.windowPtr;

center = [W / 2, H / 2];
Screen('FillOval', windowPtr, settings.intertrial.color, ...
  centerRectDims(center, settings.intertrial.dims));
Screen('flip', windowPtr);
Data = timeIntertrial(Data, settings);
if exist('callback', 'var') & isHandle(callback)
  Data = callback(Data, settings);
end
end

% Local function with timing responsibility
function Data = timeIntertrial(Data, settings)
trial = Data.currTrial;
Data.trialTime(trial).ITIStartTime = datevec(now);

elapsedTime = etime(datevec(now), Data.trialTime(trial).trialStartTime);

totalTrialTime = settings.game.choiceDisplayDur + ...
  settings.game.responseWindowDur + ...
  settings.game.feedbackDur + ...
  settings.game.ITIs(trial);
while elapsedTime < totalTrialTime
    elapsedTime = etime(datevec(now), Data.trialTime(trial).trialStartTime);
end
end
