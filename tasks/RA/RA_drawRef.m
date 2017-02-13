function RA_drawRef(blockSettings, trialSettings)
% RA_DRAWREF Draws the stable reference value on screen for monetary R&A.

%% 1. Obtain values
% Check if there is any specific reference side & value defined for this trial,
% or for this block; if neither, generate one at random. (The values keep
% getting overwritten with more specific options, if available.)
%
% NOTE: While you `drawRef` need not implement this relatively complex refSide
% search, it is a useful example. You should feel free to assume that refSide
% is wherever you place it.
if isfield(blockSettings, 'perUser') && isfield(blockSettings.perUser, 'refSide')
    referenceSide = blockSettings.perUser.refSide;
    if isfield(blockSettings.game.levels, 'reference')
        referenceValue = blockSettings.game.levels.reference;
    end
end

if exist('trialSettings', 'var')
    if isfield(trialSettings, 'refSide')
        referenceSide = trialSettings.refSide;
    elseif isfield(trialSettings, 'referenceSide')
        referenceSide = trialSettings.referenceSide;
    end

    % NOTE: trialSettings is, by convention, a table, so it doesn't respond to
    % `isfield` - would have to convert to struct
    if ismember('reference', trialSettings.Properties.VariableNames)
        referenceValue = trialSettings.reference;
    end
end

%% 2. Check values
if ~exist('referenceSide', 'var')
    referenceSide = randi(2);
    warning('Reference side not supplied; picking %d at random', referenceSide);
end

if ~exist('referenceValue', 'var')
    error('Reference value not set in either blockSettings or trialSettings!');
end

%% 3. Calculate position
H = blockSettings.device.screenDims(3);
W = blockSettings.device.screenDims(4);

if referenceSide == 1
    refDims.x = 0.25 * W;
elseif referenceSide == 2
    refDims.x = 0.75 * W;
end
refDims.y = H/4;

displayText = dollarFormatter(referenceValue);

Screen('TextSize', blockSettings.device.windowPtr, ...
    blockSettings.objects.reference.fontSize);
DrawFormattedText(blockSettings.device.windowPtr, displayText, refDims.x, ...
    refDims.y, blockSettings.default.fontColor);
end

