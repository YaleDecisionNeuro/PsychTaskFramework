function drawFeedback(trialData, blockConfig)
% Draws the feedback according to trial data and config.
%
% Args:
%   trialData: The participant data from a trial
%   blockConfig: The block settings
%
% Returns:
%   Like all draw functions, it has no return.
%
% Todo: 
%   If blockConfig.draw.lottery.verticalLayout is set to true, the feedback
%   should be be drawn to the side vertically rather than horizontally.

windowPtr = blockConfig.device.windowPtr;
W = blockConfig.device.windowWidth; % width
H = blockConfig.device.windowHeight; % height
center = [W / 2, H / 2];

feedbackSize = blockConfig.draw.feedback.dims;
pxOffCenter = [0.05 * W, 0];

% NOTE: Use structs / element class?
button1 = centerRectDims(center, feedbackSize, -pxOffCenter);
button2 = centerRectDims(center, feedbackSize, pxOffCenter);

button1_color = blockConfig.draw.feedback.colorNoAnswer;
button2_color = blockConfig.draw.feedback.colorNoAnswer;

%% Record choice & assign feedback color
% TODO: If a function can translate choice + refSide into a lottery choice,
% this could flag stochastic dominance violations as they happen
if trialData.choice == 1
    button1_color = blockConfig.draw.feedback.colorAnswer;
elseif trialData.choice == 2
    button2_color = blockConfig.draw.feedback.colorAnswer;
end

%% Display feedback (two squares)
Screen('FillRect', windowPtr, button1_color, button1);
Screen('FillRect', windowPtr, button2_color, button2);
end
