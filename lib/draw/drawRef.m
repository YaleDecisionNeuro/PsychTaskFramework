function drawRef(blockConfig, trialData)
% DRAWREF Draws the stable reference value on screen.

%% 1. Obtain values
[ referenceSide, referenceValue ] = getReferenceSideAndValue(trialData, blockConfig);

%% 2. Calculate position
W = blockConfig.device.windowWidth;
H = blockConfig.device.windowHeight;
windowPtr = blockConfig.device.windowPtr;

%% 3. Display textual reference
% FIXME: This could use refactoring & matrix algebra
if isfield(blockConfig.objects.lottery, 'verticalLayout') && ...
  blockConfig.objects.lottery.verticalLayout == true
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

Screen('TextSize', windowPtr, blockConfig.objects.reference.fontSize);

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

%% Helper function
function [ referenceSide, referenceValue ] = getReferenceSideAndValue(trialData, blockConfig)
% Check if there is any specific reference side & value defined for this trial,
% or for this block. If reference side is unavailable, generate it at random.

% Approach: Start from general options and overwrite with more specific ones

% a. Check in blockConfig
if isfield(blockConfig, 'runSetup') && isfield(blockConfig.runSetup, 'refSide')
  referenceSide = blockConfig.runSetup.refSide;
end

if isfield(blockConfig.trial.generate, 'reference')
  referenceValue = blockConfig.trial.generate.reference;
end

% b. check in trialData
% NOTE: trialData is, by convention, a table, so it doesn't respond to
% `isfield` - would have to convert to struct
trialVars = trialData.Properties.VariableNames;

if ismember('refSide', trialVars)
  referenceSide = trialData.refSide;
elseif ismember('referenceSide', trialVars)
  referenceSide = trialData.referenceSide;
end

if ismember('reference', trialVars)
  referenceValue = trialData.reference;
end

%% 2. Check values
if ~exist('referenceSide', 'var')
  referenceSide = randi(2);
  warning('Reference side not supplied; picking %d at random', referenceSide);
end

if ~exist('referenceValue', 'var')
  error('Reference value not set in either blockConfig or trialData!');
end
end
