function drawRef(settings, referenceSide)
% Draws the stable reference value on screen *for this particular experiment*
%
% For custom use, this function needs to be re-written accordingly (or a
% function handle passed in its stead).

H = settings.device.screenDims(3);
W = settings.device.screenDims(4);

if referenceSide == 1
    refDims.x = 0.25 * W;
elseif referenceSide == 2
    refDims.x = 0.75 * W;
end
refDims.y = H/4;

displayText = sprintf(settings.reference.format, settings.game.reference);

Screen('TextSize', settings.device.windowPtr, settings.reference.fontSize);
DrawFormattedText(settings.device.windowPtr, displayText, refDims.x, refDims.y, ...
    settings.default.fontColor);
end

