function [ Data ] = drawFeedback(Data, settings, callback)
W = settings.device.screenDims(3); % width
H = settings.device.screenDims(4); % height
center = [W / 2, H / 2];
windowPtr = settings.device.windowPtr;
trial = Data.currTrial;

feedbackSize = settings.feedback.dims;
pxOffCenter = [0.05 * W, 0];

% NOTE: Use structs / element class?
button1 = centerRectDims(center, feedbackSize, -pxOffCenter);
button2 = centerRectDims(center, feedbackSize, pxOffCenter);

button1_color = settings.feedback.colorNoAnswer;
button2_color = settings.feedback.colorNoAnswer;

%% Record choice & assign feedback color
% TODO: If a function can translate choice + refSide into a lottery choice,
% this could flag stochastic dominance violations as they happen
if Data.choice(trial) == 1
    button1_color = settings.feedback.colorAnswer;
elseif Data.choice(trial) == 2
    button2_color = settings.feedback.colorAnswer;
end

%% Display feedback (two squares)
Screen('FillRect', windowPtr, button1_color, button1);
Screen('FillRect', windowPtr, button2_color, button2);

% Re-draw reference and note feedback length
Screen('flip', windowPtr); % NOTE: This makes no sense. Why are we using it if we're not taking our time measurements from it?

Data.trialTime(trial).feedbackStartTime = datevec(now);
elapsedTime = etime(datevec(now), Data.trialTime(trial).feedbackStartTime);
while elapsedTime < settings.game.feedbackDur
    elapsedTime = etime(datevec(now), Data.trialTime(trial).feedbackStartTime);
end

  timeFeedback(Data, settings);
if exist('callback', 'var') && isHandle(callback)
  Data = callback(Data, settings);
end
end

% Local function with timing responsibility
function Data = timeFeedback(Data, settings)

end
