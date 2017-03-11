function [ trialData ] = SODM_drawTask(trialData, trialSettings, blockSettings, callback)
% SODM_DRAWTASK Executes the SODM trial stage of showing the task choice to
%   the participant. Choice values are derived from `trialSettings` and,
%   if need be, `blockSettings`.

windowPtr = blockSettings.device.windowPtr;

% Determine probabilities to associate with colors
[probOrder, amtOrder] = orderLotto(trialSettings);

% FIXME: Semantic naming
redProb = probOrder(1);
blueProb = probOrder(2);

W = blockSettings.device.windowWidth; % width
H = blockSettings.device.windowHeight; % height

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
% NOTE: Order of colors remains constant: one is always on top, the other
% always on bottom
colors = blockSettings.objects.lottery.figure.colors.prob;
color_ambig = blockSettings.objects.lottery.figure.colors.ambig;
color_bgr = blockSettings.default.bgrColor;

% NOTE: The lottery is always displayed in the horizontal center of the screen
screenCenter = W / 2;
halfBox = blockSettings.objects.lottery.figure.dims(1) / 2;

% Paint the whole screen (default without coordinates)
Screen('FillRect', windowPtr, color_bgr);
blockSettings.game.bgrDrawFn(blockSettings);

% Draw reference
blockSettings.game.referenceDrawFn(blockSettings, trialSettings);

% Draw the lottery box
lottoDims = [screenCenter - halfBox, Y1, screenCenter + halfBox, Y2];
Screen('FillRect', windowPtr, colors(1, :), lottoDims);

lottoDims = [screenCenter - halfBox, Y2, screenCenter + halfBox, Y3];
Screen('FillRect', windowPtr, colors(2, :), lottoDims);

% Occluder is painted over
lottoAmbigDims = [screenCenter - halfBox, Y2occ, screenCenter + halfBox, Y3occ];
Screen('FillRect', windowPtr, color_ambig, lottoAmbigDims);

%% Draw the stakes
% Retrieve the dimensions (due to different length) of the amount labels
% Value to be looked up is stored in amtOrder

% NOTE: txtDims will not be correct if there's a linebreak in the text - why?
% NOTE: PTB will break line when \n is encountered, but neither MATLAB nor it
%   will treat \n in the string as a newline. You might need to use the MATLAB
%   function `newline` to deal with this.

% 1. Draw text of stakes
Screen(windowPtr, 'TextSize', blockSettings.objects.lottery.stakes.fontSize);
[ txt1, txtDims1 ] = textLookup(amtOrder(1), blockSettings.lookups.stakes.txt, ...
  windowPtr);
[ txt2, txtDims2 ] = textLookup(amtOrder(2), blockSettings.lookups.stakes.txt, ...
  windowPtr);

topTxtCoords = [W/2 - txtDims1(1)/2, Y1 - txtDims1(2)/2];
bottomTxtCoords = [W/2 - txtDims2(1)/2, Y3 + txtDims2(2)];
% NOTE: y-coordinates are baselines for DrawFormattedText, hence the difference
%   -- the top text doesn't need to dodge as much as the bottom text does

DrawFormattedText(windowPtr, txt1, ...
  topTxtCoords(1), topTxtCoords(2), blockSettings.objects.lottery.stakes.fontColor);
DrawFormattedText(windowPtr, txt2, ...
  bottomTxtCoords(1), bottomTxtCoords(2), blockSettings.objects.lottery.stakes.fontColor);

% 2. Draw images of stakes
[ texture1, textureDims1 ] = imgLookup(amtOrder(1), ...
  blockSettings.lookups.stakes.img, blockSettings.textures);
[ texture2, textureDims2 ] = imgLookup(amtOrder(2), ...
  blockSettings.lookups.stakes.img, blockSettings.textures);

padding = 10; % Space to leave between precise boundaries
bottomXY = [screenCenter - textureDims1(1)/2, Y3 + txtDims1(2) + padding];
bottomCoords = xyAndDimsToRect(bottomXY, textureDims1);

% y-dim: Dodge the image from both lottery and the text, and leave some space
topXY = [screenCenter - textureDims2(1)/2, ...
  Y1 - textureDims2(2) - txtDims2(2) - padding];
topCoords = xyAndDimsToRect(topXY, textureDims2);

Screen('DrawTexture', windowPtr, texture1, [], topCoords);
Screen('DrawTexture', windowPtr, texture2, [], bottomCoords);

%% Draw probability numbers
% 1. Compute probability numbers to display & convert to text
probNumbers = probOrder - ambig / 2; % Keeps the numbers same if no ambiguity
probTxt1 = num2str(probNumbers(1) * 100);
probTxt2 = num2str(probNumbers(2) * 100);

% 2. Compute dimensions
Screen(windowPtr, 'TextSize', blockSettings.objects.lottery.probLabels.fontSize);
textDim = zeros(2, 2); % top row is the top probability, bottom row the bottom
textDim(1, :) = getTextDims(windowPtr, probTxt1);
textDim(2, :) = getTextDims(windowPtr, probTxt2);

% 3. Compute coordinates
xCoord = W/2 - textDim(1, 1)/2;

% DrawFormattedText's y coordinate is not the *top*, it's the *baseline*
adjustToBaseline = textDim(:, 2)' / 3;
yCoord = [Y1 + 0.5 * (Y2 - Y1), Y2 + 0.5 * (Y3 - Y2)] + adjustToBaseline;

% Logic of `ambig / 4`: only half the ambiguity diminishes either side of the
% probability, and it cuts the position of text in another half
ambigYAdjustment = boxHeight * ambig / 4;
yCoord = yCoord + [-ambigYAdjustment, ambigYAdjustment];

% 4. Draw the text
DrawFormattedText(windowPtr, sprintf('%s', probTxt1), xCoord, yCoord(1), ...
  blockSettings.objects.lottery.probLabels.fontColor);
DrawFormattedText(windowPtr, sprintf('%s', probTxt2), xCoord, yCoord(2), ...
  blockSettings.objects.lottery.probLabels.fontColor);

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
