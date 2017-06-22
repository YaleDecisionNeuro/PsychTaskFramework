function drawLotto(trialData, blockConfig)
% DrawLotto Using an open PTB screen and other properties of blockConfig,
%   draws a lottery with values specified in trialData in the center of
%   the screen.
%
% If blockConfig.draw.lottery.offCenterByPx exists, drawLotto will shift
% the lottery by the specified amount of pixels.

%% 1. Extract config
% Device
windowPtr = blockConfig.device.windowPtr;
W = blockConfig.device.windowWidth; % width
H = blockConfig.device.windowHeight; % height
screenCenter = W / 2; % NOTE: screenCenterX

% Lottery box properties
boxHeight = blockConfig.draw.lottery.box.dims(2);
halfBoxWidth = blockConfig.draw.lottery.box.dims(1) / 2;
if isfield(blockConfig.draw.lottery.box, 'occluderWidth')
  halfOccluderWidth = blockConfig.draw.lottery.box.occluderWidth / 2;
else
  halfOccluderWidth = halfBoxWidth;
end

% Shuffling lotto away from screen-center
offCenterByPx = [0 0];
if isfield(blockConfig.draw.lottery, 'offCenterByPx')
  offCenterByPx = blockConfig.draw.lottery.offCenterByPx(:)';
else
  % Create a field so that it doesn't have to be passed to sub-functions
  blockConfig.draw.lottery.offCenterByPx = offCenterByPx;
end
offCenterRect = repmat(offCenterByPx, [1 2]); % Useful for texture rect coords

% Padding: how much space to leave between precise boundaries
if isfield(blockConfig.graphicDefault, 'padding')
  padding = blockConfig.graphicDefault.padding;
else
  padding = 10;
end

% Colors
% NOTE: The order of colors remains the same: color(1, :) is on top
colors = blockConfig.draw.lottery.box.probColors;
ambigColor = blockConfig.draw.lottery.box.ambigColors;

% Trial
ambig = trialData.ambigs;
% Color 1 is on top, color 2 is on the bottom. If trialData.color == 1,
%   the winning number should be on top (and with default colors, red.) It
%   should be at the bottom & blue otherwise.
[probs, payoffs] = orderLotto(trialData);
% If occluder exists, it lessens displayed prob numbers
displayProbNumbers = probs - ambig / 2;

%% 2. Compute positions
% Basic box
Y1 = (H - boxHeight) / 2; % Top Y coordinate of the box's top
Y2 = Y1 + boxHeight * probs(1); % Y coordinate where top & bottom parts meet
Y3 = Y2 + boxHeight * probs(2); % Y coordinate of the box's bottom

% Occluder (hides equal amounts of probability from both top and bottom)
Y2occ = Y2 - boxHeight * ambig / 2; % Top of occluder
Y3occ = Y2 + boxHeight * ambig / 2; % Bottom of occluder

%% 3. Draw the lottery box
% Draw probability boxes
topBoxDims = [screenCenter - halfBoxWidth, Y1, ...
  screenCenter + halfBoxWidth, Y2] + offCenterRect;
Screen('FillRect', windowPtr, colors(1, :), topBoxDims);

bottomBoxDims = [screenCenter - halfBoxWidth, ...
  Y2, screenCenter + halfBoxWidth, Y3] + offCenterRect;
Screen('FillRect', windowPtr, colors(2, :), bottomBoxDims);

% Paint occluder over probability boxes
occluderDims = [screenCenter - halfOccluderWidth, Y2occ, ...
  screenCenter + halfOccluderWidth, Y3occ] + offCenterRect;
Screen('FillRect', windowPtr, ambigColor, occluderDims);

%% 4. Draw the probabilities
% Determine the dimensions
Screen(windowPtr, 'TextSize', blockConfig.draw.lottery.probLabels.fontSize);
topProbString = sprintf('%.f', displayProbNumbers(1) * 100);
topProbTextDims = getTextDims(windowPtr, topProbString);
bottomProbString = sprintf('%.f', displayProbNumbers(2) * 100);
bottomProbTextDims = getTextDims(windowPtr, bottomProbString);

% Determine the position
% a. How much to vertically adjust by due to occluder?
% (Logic of `/4`: only half the ambiguity diminishes either side of the
% probability, and it cuts the position of text in another half)
ambigYAdjustment = boxHeight * ambig / 4;

% b. Set the coordinates
topXY = [W/2 - topProbTextDims(1)/2, ...
         Y1 + 0.5 * (Y2 - Y1) - ambigYAdjustment + topProbTextDims(2)/3] ...
  + offCenterByPx;
botXY = [W/2 - bottomProbTextDims(1)/2, ...
         Y2 + 0.5 * (Y3 - Y2) + ambigYAdjustment + bottomProbTextDims(2)/3] ...
  + offCenterByPx;
% Logic of `/3`: the text dimensions include some line-height, so `/2` shifts too much

% Draw!
probColor = blockConfig.draw.lottery.probLabels.fontColor;
DrawFormattedText(windowPtr, topProbString, topXY(1), topXY(2), probColor);
DrawFormattedText(windowPtr, bottomProbString, botXY(1), botXY(2), probColor);

%% 5. Draw the payoffs
% Choose how to display the payoff (different function for monetary amounts,
%   vs. for images with labels)
if configHasLookups(blockConfig)
  drawPayoffImageAndLabel(payoffs);
else
  drawPayoffAmount(payoffs);
end

%% Nested functions,
% (as it's useful to separate the logic while accessing to prior computations)
function drawPayoffImageAndLabel(payoffs)
  % 1. Draw labels
  Screen(windowPtr, 'TextSize', blockConfig.draw.lottery.stakes.fontSize);
  lookupTbl = blockConfig.runSetup.lookups.txt;
  [ botLabel, botLabelDims ] = textLookup(payoffs(1), lookupTbl, windowPtr);
  [ topLabel, topLabelDims ] = textLookup(payoffs(2), lookupTbl, windowPtr);

  topLabelXY = [W/2 - topLabelDims(1)/2, Y3 + topLabelDims(2)] ...
    + offCenterByPx;
  botLabelXY = [W/2 - botLabelDims(1)/2, Y1 - botLabelDims(2)/2] ...
    + offCenterByPx;

  payoffColor = blockConfig.draw.lottery.stakes.fontColor;
  DrawFormattedText(windowPtr, topLabel, topLabelXY(1), topLabelXY(2), payoffColor);
  DrawFormattedText(windowPtr, botLabel, botLabelXY(1), botLabelXY(2), payoffColor);

  % 2. Draw images of stakes
  imgLookupTbl = blockConfig.runSetup.lookups.img;
  textureBank = blockConfig.runSetup.textures;
  [ botImg, botImgDims ] = imgLookup(payoffs(1), imgLookupTbl, textureBank);
  [ topImg, topImgDims ] = imgLookup(payoffs(2), imgLookupTbl, textureBank);

  bottomXY = [screenCenter - botImgDims(1)/2, ...
              Y1 - topImgDims(2) - topLabelDims(2) - padding];
  bottomCoords = xyAndDimsToRect(bottomXY, botImgDims) + offCenterRect;

  % y-dim: Dodge the image from both lottery and the text, and leave some space
  topXY = [screenCenter - topImgDims(1)/2, ...
           Y3 + botLabelDims(2) + padding];
  topCoords = xyAndDimsToRect(topXY, topImgDims) + offCenterRect;

  Screen('DrawTexture', windowPtr, topImg, [], topCoords);
  Screen('DrawTexture', windowPtr, botImg, [], bottomCoords);
end

function drawPayoffAmount(payoffs)
  % 1. Get text dimensions & string
  Screen(windowPtr, 'TextSize', blockConfig.draw.lottery.stakes.fontSize);
  [ topPayoffString, topPayoffDims ] = dollarFormatter(payoffs(1), windowPtr);
  [ botPayoffString, botPayoffDims ] = dollarFormatter(payoffs(2), windowPtr);

  % 2. Calculate text position
  padding = 20;
  topXY = [W/2 - topPayoffDims(1)/2, ...
           Y1 - padding] + offCenterByPx;
  botXY = [W/2 - botPayoffDims(1)/2, ...
           Y3 + botPayoffDims(2)] + offCenterByPx;

  % 3. Draw!
  payoffColor = blockConfig.draw.lottery.stakes.fontColor;
  DrawFormattedText(windowPtr, topPayoffString, topXY(1), topXY(2), payoffColor);
  DrawFormattedText(windowPtr, botPayoffString, botXY(1), botXY(2), payoffColor);
end
end
