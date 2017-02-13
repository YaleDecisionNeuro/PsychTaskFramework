function MDM_drawRef(blockSettings, trialSettings)
% MDM_DRAWREF Draws the stable reference value on screen for the MDM task.

% Assume that reference value is found in trialSettings.reference
referenceValue = trialSettings.reference;
% Assume that reference side is saved for block
referenceSide = blockSettings.perUser.refSide;

H = blockSettings.device.screenDims(3);
W = blockSettings.device.screenDims(4);
windowPtr = blockSettings.device.windowPtr;

if referenceSide == 1
  refDims.x = 0.25 * W;
elseif referenceSide == 2
  refDims.x = 0.75 * W;
else
  error('Illegal `referenceSide` argument, legal values are 1 or 2.');
end
refDims.y = H/4;

Screen('TextSize', blockSettings.device.windowPtr, blockSettings.objects.reference.fontSize);
[ txt, txtDims ] = textLookup(referenceValue, blockSettings.lookups.stakes.txt, ...
  windowPtr);
[ texture, textureDims ] = imgLookup(referenceValue, blockSettings.lookups.stakes.img, ...
  blockSettings.textures);

DrawFormattedText(windowPtr, txt, refDims.x - txtDims(1)/2, refDims.y, ...
    blockSettings.default.fontColor);
Screen('DrawTexture', windowPtr, texture, [], [refDims.x, refDims.y, ...
    refDims.x + textureDims(1), refDims.y + textureDims(2)]);
end
