function [ Data ] = drawTask(Data, settings, callback)
trial = Data.currTrial;
windowPtr = settings.device.windowPtr;

% Determine probabilities to associate with colors
[probOrder, amtOrder] = orderLotto(settings, trial);

% FIXME: Semantic naming
redProb = probOrder(1);
blueProb = probOrder(2);

% FIXME: This, technically, is only the bottom-right coordinate. If `rect`
% passed to Screen('OpenWindow', rect) began with two non-zero values, that's
% how far from the top-left of the screen PTB would start drawing.
W = settings.device.screenDims(3); % width
H = settings.device.screenDims(4); % height

boxHeight = settings.lottery.figure.dims(2);
Y1 = (H - boxHeight) / 2; % Space over the lottery box (top coordinate of display)
Y2 = Y1 + boxHeight * redProb; % Y coordinate of top probability's bottom
Y3 = Y2 + boxHeight * blueProb; % Y coordinate of bottom probability's bottom

% Occluder coordinates
ambig = settings.game.ambigs(trial);
nonAmbigPart = 1 - ambig; % how much of the prob box is definite?
Y2occ = Y1 + boxHeight * (nonAmbigPart / 2); % top of occluder
Y3occ = Y2occ + boxHeight * ambig; % bottom of occluder

% Colors
% NOTE: Order of colors remains constant
colors = settings.lottery.figure.colors.prob;
color_ambig = settings.lottery.figure.colors.ambig;
color_bgr = settings.background.color;

% NOTE: The lottery is always displayed in the horizontal center of the screen
screenCenter = W / 2;
halfBox = settings.lottery.figure.dims(1) / 2;

% Paint the whole screen (default without coordinates)
Screen('FillRect', windowPtr, color_bgr);

drawRef(settings, Data.refSide)

lottoDims = [screenCenter - halfBox, Y1, screenCenter + halfBox, Y2];
Screen('FillRect', windowPtr, colors(1, :), lottoDims);

lottoDims = [screenCenter - halfBox, Y2, screenCenter + halfBox, Y3];
Screen('FillRect', windowPtr, colors(2, :), lottoDims);

clear lottoDims;

% Occluder is painted over
lottoAmbigDims = [screenCenter - halfBox, Y2occ, screenCenter + halfBox, Y3occ];
Screen('FillRect', windowPtr, color_ambig, lottoAmbigDims);

%% Draw the amounts! Red is always on top
% Retrieve the dimensions (due to different length) of the amount labels
%
% There are hard-coded `.Digit1`, `.Digit2` and `.Digit3` values in config,
% which denote the size that number will have with that amount of digits.
%
% TODO: Screen('TextBounds', windowPtr, text) returns what we need -- but maybe
% it's too costly to call it during every trial? (Maybe it can be done during
% setup and memoized?)
digitWidth = ones(1, 2);
digitHeight = ones(1, 2);
for i = 1:length(amtOrder)
  digit_field = sprintf('Digit%g', length(num2str(amtOrder(i))));
  temp = settings.lottery.stakes.misc.(digit_field);
  digitWidth(i) = temp(1);
  digitHeight(i) = temp(2);
end
clear temp;

randomConstantAdjustment = 50; % FIXME: Random constant adjustment
xCoords = [W/2 - digitWidth(1)/2, W/2 - digitWidth(2)/2];
yCoords = [Y3, Y1 - digitHeight(1)] + randomConstantAdjustment;

Screen(windowPtr, 'TextSize', settings.lottery.stakes.fontSize);
DrawFormattedText(windowPtr, sprintf('$%s', num2str(amtOrder(1))), ...
  xCoords(1), yCoords(1), settings.lottery.stakes.fontColor);
DrawFormattedText(windowPtr, sprintf('$%s', num2str(amtOrder(2))), ...
  xCoords(2), yCoords(2), settings.lottery.stakes.fontColor);

%% Draw probability numbers
% Compute coordinates
% This time, we assume all probabilities are double-digit
textDim = settings.lottery.probLabels.dims;

xCoord = W/2 - textDim(1)/2;
yCoord = [Y1 + 0.5 * (Y2 - Y1) - textDim(2)/2, ...
  Y2 + 0.5 * (Y3 - Y2) - textDim(2)/2];

% Logic of `/4`: only half the ambiguity diminishes either side of the
% probability, and it cuts the position of text in another half
ambigYAdjustment = boxHeight * ambig / 4;
yCoord = yCoord + [-ambigYAdjustment, ambigYAdjustment] + randomConstantAdjustment / 2;

probNumbers = probOrder - ambig / 2; % Keeps the numbers same if no ambiguity

Screen(windowPtr, 'TextSize', settings.lottery.probLabels.fontSize);
DrawFormattedText(windowPtr, sprintf('%s', num2str(probNumbers(1)*100)), ...
  xCoord, yCoord(1), settings.lottery.probLabels.fontColor);
DrawFormattedText(windowPtr, sprintf('%s', num2str(probNumbers(2)*100)), ...
  xCoord, yCoord(2), settings.lottery.probLabels.fontColor);

Screen('flip', windowPtr);

%% Handle the display properties & book-keeping
Data = timeAndRecordTask(Data, settings);

% Allow the execution of a callback if passed
if exist('callback', 'var') && isHandle(callback)
  Data = callback(Data, settings);
end
end

% Local function with timing responsibility
function Data = timeAndRecordTask(Data, settings)
  % Extract to local variables now because struct field access costs time
  t = Data.currTrial;
  trialStart = Data.trialTime(t).trialStartTime;
  trialDur = settings.game.choiceDisplayDur;

  elapsedTime = etime(datevec(now), trialStart);
  while elapsedTime < trialDur
      elapsedTime = etime(datevec(now), trialStart);
  end

  Data.vals(t) = settings.game.stakes(t);
  Data.probs(t) = settings.game.probs(t);
  Data.ambigs(t) = settings.game.ambigs(t);
end
