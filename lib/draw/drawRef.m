function drawRef(blockConfig, trialData)
% Draws the stable reference value on screen.
%
% To get the side and reference value, it uses getReferenceSideAndValue, which
% searches the structures supplied as arguments.
%
% If blockConfig.draw.lottery.verticalLayout is set to true, the reference will
% be drawn to the side vertically rather than horizontally.
%
% Args:
%   blockConfig: The block settings
%   trialData: Trial properties and collected participant data
%
% Returns:
%   Like all draw functions, it has no return.

0; % to prevent sphinx from thinking that the next comment is more docstring

%% 1. Obtain values
[ referenceSide, referenceValue ] = getReferenceSideAndValue(trialData, blockConfig);

%% 2. Calculate position
W = blockConfig.device.windowWidth;
H = blockConfig.device.windowHeight;
windowPtr = blockConfig.device.windowPtr;

%% 3. Display textual reference
% FIXME: This could use refactoring & matrix algebra
if isfield(blockConfig.draw.lottery, 'verticalLayout') && ...
  blockConfig.draw.lottery.verticalLayout == true
  % Flip it around vertically
  if referenceSide == 1
    refDims.y = 0.25 * H;
  elseif referenceSide == 2
    refDims.y = 0.75 * H;
  end
  refDims.x = W/2;
else
  % Flip it around horizontally
  if referenceSide == 1
    refDims.x = 0.25 * W;
  elseif referenceSide == 2
    refDims.x = 0.75 * W;
  end
  refDims.y = H/4;
end

Screen('TextSize', windowPtr, blockConfig.draw.reference.fontSize);

if ~configHasLookups(blockConfig)
  % 1, Prepare text (and nothing else)
  displayText = dollarFormatter(referenceValue);
  textDims = getTextDims(windowPtr, displayText);
else
  % 1. Prepare text
  lookupTbl = blockConfig.runSetup.lookups.txt;
  [ displayText, textDims ] = textLookup(referenceValue, lookupTbl, windowPtr);

  % 2. Draw the reference image underneath
  imgLookupTbl = blockConfig.runSetup.lookups.img;
  textureBank = blockConfig.runSetup.textures;
  [ img, imgDims ] = imgLookup(referenceValue, imgLookupTbl, textureBank);
  Screen('DrawTexture', windowPtr, img, [], ...
    xyAndDimsToRect([refDims.x - imgDims(1)/2, refDims.y], imgDims));
end

% 3. Draw text
textPos = [refDims.x - textDims(1)/2, refDims.y - textDims(2)/2];
DrawFormattedText(windowPtr, displayText, textPos(1), ...
  textPos(2), blockConfig.graphicDefault.fontColor);
end
