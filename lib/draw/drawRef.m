function drawRef(blockSettings, trialSettings)
% DRAWREF Draws the stable reference value on screen.

%% 1. Obtain values
[ referenceSide, referenceValue ] = getReferenceSideAndValue(trialSettings, blockSettings);

%% 2. Calculate position
W = blockSettings.device.windowWidth;
H = blockSettings.device.windowHeight;

%% 3. Display textual reference
% FIXME: This could use refactoring & matrix algebra
if isfield(blockSettings.objects.lottery, 'verticalLayout') && ...
  blockSettings.objects.lottery.verticalLayout == true
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

Screen('TextSize', blockSettings.device.windowPtr, ...
  blockSettings.objects.reference.fontSize);

displayText = dollarFormatter(referenceValue);
textDims = getTextDims(blockSettings.device.windowPtr, displayText);
refDims.x = refDims.x - textDims(1)/2;
refDims.y = refDims.y - textDims(2)/2;

DrawFormattedText(blockSettings.device.windowPtr, displayText, refDims.x, ...
  refDims.y, blockSettings.default.fontColor);
end

%% Helper function
function [ referenceSide, referenceValue ] = getReferenceSideAndValue(trialSettings, blockSettings)
% Check if there is any specific reference side & value defined for this trial,
% or for this block. If reference side is unavailable, generate it at random.

% Approach: Start from general options and overwrite with more specific ones

% a. Check in blockSettings
if isfield(blockSettings, 'perUser') && isfield(blockSettings.perUser, 'refSide')
  referenceSide = blockSettings.perUser.refSide;
end

if isfield(blockSettings.game.levels, 'reference')
  referenceValue = blockSettings.game.levels.reference;
end

% b. check in trialSettings
% NOTE: trialSettings is, by convention, a table, so it doesn't respond to
% `isfield` - would have to convert to struct
trialVars = trialSettings.Properties.VariableNames;

if ismember('refSide', trialVars)
  referenceSide = trialSettings.refSide;
elseif ismember('referenceSide', trialVars)
  referenceSide = trialSettings.referenceSide;
end

if ismember('reference', trialVars)
  referenceValue = trialSettings.reference;
end

%% 2. Check values
if ~exist('referenceSide', 'var')
  referenceSide = randi(2);
  warning('Reference side not supplied; picking %d at random', referenceSide);
end

if ~exist('referenceValue', 'var')
  error('Reference value not set in either blockSettings or trialSettings!');
end
end
