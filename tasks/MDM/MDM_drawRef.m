function MDM_drawRef(blockSettings, trialSettings)
% MDM_DRAWREF Draws the stable reference value on screen for the MDM task.

% Assume that reference value is found in trialSettings.reference
referenceValue = trialSettings.reference;
% Assume that reference side is saved for block
referenceSide = blockSettings.perUser.refSide;

W = blockSettings.device.screenDims(3);
H = blockSettings.device.screenDims(4);
windowPtr = blockSettings.device.windowPtr;
Screen('TextSize', blockSettings.device.windowPtr, ...
  blockSettings.objects.reference.fontSize);

% Retrieve objects
[ txt, txtDims ] = textLookup(referenceValue, ...
  blockSettings.lookups.stakes.txt, windowPtr);
[ texture, textureDims ] = imgLookup(referenceValue, ...
  blockSettings.lookups.stakes.img, blockSettings.textures);

% Positioning logic: these are baselines for text and images, which will make
% their own adjustment to avoid collision
refDims.y = 0.5 * H;
if referenceSide == 1
  refDims.x = 0.25 * W;
elseif referenceSide == 2
  refDims.x = 0.75 * W;
else
  error('Illegal `referenceSide` argument, legal values are 1 or 2.');
end

% y-dim: Dodge the text to the top to avoid texture overlap
DrawFormattedText(windowPtr, txt, refDims.x - txtDims(1)/2, ...
  refDims.y - txtDims(2)/2, blockSettings.default.fontColor);
% y-dim: Let the texture start drawing at monitor middle
Screen('DrawTexture', windowPtr, texture, [], ...
  xyAndDimsToRect([refDims.x - textureDims(1)/2, refDims.y], textureDims));
end
