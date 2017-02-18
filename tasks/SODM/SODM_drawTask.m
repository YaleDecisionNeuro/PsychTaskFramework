function [ trialData ] = SODM_drawTask(trialData, trialSettings, blockSettings, callback)
% SODM_DRAWTASK Executes the SODM trial stage of showing the task choice to
%   the participant. Choice values are derived from `trialSettings` and,
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
blockSettings.game.bgrDrawFn(blockSettings);

MDM_drawRef(blockSettings, trialSettings);

lottoDims = [screenCenter - halfBox, Y1, screenCenter + halfBox, Y2];
Screen('FillRect', windowPtr, colors(1, :), lottoDims);

lottoDims = [screenCenter - halfBox, Y2, screenCenter + halfBox, Y3];
Screen('FillRect', windowPtr, colors(2, :), lottoDims);

clear lottoDims;

% Occluder is painted over
lottoAmbigDims = [screenCenter - halfBox, Y2occ, screenCenter + halfBox, Y3occ];
Screen('FillRect', windowPtr, color_ambig, lottoAmbigDims);

%% Draw the stakes
% Retrieve the dimensions (due to different length) of the amount labels
% Value to be looked up is stored in amtOrder
Screen(windowPtr, 'TextSize', blockSettings.objects.lottery.stakes.fontSize);

% Draw text
[ txt1, txtDims1 ] = textLookup(amtOrder(1), blockSettings.lookups.stakes.txt, ...
  windowPtr);
[ txt2, txtDims2 ] = textLookup(amtOrder(2), blockSettings.lookups.stakes.txt, ...
  windowPtr);

randomConstantAdjustment = 50; % FIXME: Random constant adjustment
xCoords = [W/2 - txtDims1(1)/2, W/2 - txtDims2(1)/2];
yCoords = [Y3, Y1 - txtDims1(2)] + randomConstantAdjustment;

DrawFormattedText(windowPtr, txt1, ...
  xCoords(1), yCoords(1), blockSettings.objects.lottery.stakes.fontColor);
DrawFormattedText(windowPtr, txt2, ...
  xCoords(2), yCoords(2), blockSettings.objects.lottery.stakes.fontColor);

% Draw images
[ texture1, textureDims1 ] = imgLookup(amtOrder(1), blockSettings.lookups.stakes.img, ...
  blockSettings.textures);
[ texture2, textureDims2 ] = imgLookup(amtOrder(2), blockSettings.lookups.stakes.img, ...
  blockSettings.textures);

Screen('DrawTexture', windowPtr, texture1, [], [xCoords(1) yCoords(1) xCoords(1) + textureDims1(1) yCoords(1) + textureDims1(2)]);
Screen('DrawTexture', windowPtr, texture2, [], [xCoords(2) yCoords(2) xCoords(2) + textureDims2(1) yCoords(2) + textureDims2(2)]);

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
  % Extract to local variables now because struct field access costs time
  displayStart = trialData.choiceStartTime;
  displayDur = blockSettings.game.durations.choice;

  elapsedTime = etime(datevec(now), displayStart);
  while elapsedTime < displayDur
    % Add sleep(0.05) to not fry the computer?
    [keyisdown, secs, keycode, deltaSecs] = KbCheck;
    % breakKeys = [KbName('2@'), KbName('1!')]
    if keyisdown && (keycode(KbName('2@')) || keycode(KbName('1!')))
      elapsedTime = etime(datevec(now), displayStart);
      break
    end
    elapsedTime = etime(datevec(now), displayStart);
  end
  trialData.rt = elapsedTime;
  trialData.rt_ci = deltaSecs;

  %% Record choice & assign feedback color
  % TODO: If a function can translate choice + refSide into a lottery choice,
  % this could flag stochastic dominance violations as they happen
  % (or at least make it clearer whether the participant opted for lottery
  % both for evaluation and later analysis)
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
