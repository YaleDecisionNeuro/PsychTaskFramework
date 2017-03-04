function [ trialData ] = SODM_drawMonTask(trialData, trialSettings, blockSettings, callback)
% RA_DRAWTASK Executes the monetary R&A trial stage of showing the task choice
%   to the participant. Choice values are derived from `trialSettings` and,
%   if need be, `blockSettings`.

windowPtr = blockSettings.device.windowPtr;

% Determine probabilities to associate with colors
[probOrder, amtOrder] = orderLotto(trialSettings);
% FIXME: How does this work when we have a color?

% FIXME: Semantic naming
redProb = probOrder(1);
blueProb = probOrder(2);

% FIXME: This, technically, is only the bottom-right coordinate. If `rect`
% passed to Screen('OpenWindow', rect) began with two non-zero values, that's
% how far from the top-left of the screen PTB would start drawing.
W = blockSettings.device.screenDims(3); % width
H = blockSettings.device.screenDims(4); % height

boxHeight = blockSettings.objects.lottery.figure.dims(2);
Y1 = (H - boxHeight) / 2; % Space over the lottery box (top coordinate of display)
Y2 = Y1 + boxHeight * redProb; % Y coordinate of top probability's bottom
Y3 = Y2 + boxHeight * blueProb; % Y coordinate of bottom probability's bottom

% Occluder coordinates
ambig = trialSettings.ambigs;
nonAmbigPart = 1 - ambig; % how much of the prob box is definite?
Y2occ = Y1 + boxHeight * (nonAmbigPart / 2); % top of occluder
Y3occ = Y2occ + boxHeight * ambig; % bottom of occluder

% Colors
% NOTE: Order of colors remains constant
colors = blockSettings.objects.lottery.figure.colors.prob;
color_ambig = blockSettings.objects.lottery.figure.colors.ambig;
color_bgr = blockSettings.default.bgrColor;

% NOTE: The lottery is always displayed in the horizontal center of the screen
screenCenter = W / 2;
halfBox = blockSettings.objects.lottery.figure.dims(1) / 2;

% Paint the whole screen (default without coordinates)
Screen('FillRect', windowPtr, color_bgr);
if isfield(blockSettings.game, 'bgrDrawFn') && ...
    isa(blockSettings.game.bgrDrawFn, 'function_handle')
  blockSettings.game.bgrDrawFn(blockSettings);
end

RA_drawRef(blockSettings, trialSettings)

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
  % Quickfix to issues with negative numbers
  digitString = num2str(amtOrder(i));
  digitCount = length(digitString);
  if amtOrder(i) < 0
    digitCount = digitCount - 1;
  end

  digit_field = sprintf('Digit%g', length(digitCount));
  temp = blockSettings.objects.lottery.stakes.misc.(digit_field);
  digitWidth(i) = temp(1);
  digitHeight(i) = temp(2);
end
clear temp;

randomConstantAdjustment = 50; % FIXME: Random constant adjustment
xCoords = [W/2 - digitWidth(1)/2, W/2 - digitWidth(2)/2];
yCoords = [Y3, Y1 - digitHeight(1)] + randomConstantAdjustment;

Screen(windowPtr, 'TextSize', blockSettings.objects.lottery.stakes.fontSize);
DrawFormattedText(windowPtr, dollarFormatter(amtOrder(1)), ...
  xCoords(1), yCoords(1), blockSettings.objects.lottery.stakes.fontColor);
DrawFormattedText(windowPtr, dollarFormatter(amtOrder(2)), ...
  xCoords(2), yCoords(2), blockSettings.objects.lottery.stakes.fontColor);

%% Draw probability numbers
% Compute coordinates
% This time, we assume all probabilities are double-digit
textDim = blockSettings.objects.lottery.probLabels.dims;

xCoord = W/2 - textDim(1)/2;
yCoord = [Y1 + 0.5 * (Y2 - Y1) - textDim(2)/2, ...
  Y2 + 0.5 * (Y3 - Y2) - textDim(2)/2];

% Logic of `/4`: only half the ambiguity diminishes either side of the
% probability, and it cuts the position of text in another half
ambigYAdjustment = boxHeight * ambig / 4;
yCoord = yCoord + [-ambigYAdjustment, ambigYAdjustment] + randomConstantAdjustment / 2;

probNumbers = probOrder - ambig / 2; % Keeps the numbers same if no ambiguity

Screen(windowPtr, 'TextSize', blockSettings.objects.lottery.probLabels.fontSize);
DrawFormattedText(windowPtr, sprintf('%s', num2str(probNumbers(1)*100)), ...
  xCoord, yCoord(1), blockSettings.objects.lottery.probLabels.fontColor);
DrawFormattedText(windowPtr, sprintf('%s', num2str(probNumbers(2)*100)), ...
  xCoord, yCoord(2), blockSettings.objects.lottery.probLabels.fontColor);

Screen('flip', windowPtr);
trialData.choiceStartTime = datevec(now);

%% Handle the display properties & book-keeping
trialData = timeAndRecordTask(trialData, trialSettings, blockSettings);

% Allow the execution of a callback if passed
if exist('callback', 'var') && isa(callback, 'function_handle')
  trialData = callback(trialData, trialSettings, blockSettings);
end
end

% Local function with timing responsibility
function trialData = timeAndRecordTask(trialData, trialSettings, blockSettings)
  %% Record choice & assign feedback color
  [keyisdown, trialData.rt, keycode, trialData.rt_ci] = ...
    waitForKey({'1!', '2@'}, blockSettings.game.durations.choice);
  if keyisdown && keycode(KbName('1!'))
      trialData.choice = 1;
  elseif keyisdown && keycode(KbName('2@'))
      trialData.choice = 2;
  else % non-press
      trialData.choice = 0;
      trialData.rt = NaN;
  end
  trialData.choseLottery = keyToChoice(trialData.choice, ...
    blockSettings.perUser.refSide);
end
