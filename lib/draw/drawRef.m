function drawRef(settings, referenceSide)
% DRAWREF Draws the stable reference value on screen for monetary R&A.
%
% For use in other tasks, you'll likely need to write a custom function for
% reference display (unless your reference is a monetary amount in dollars).

H = settings.device.screenDims(3);
W = settings.device.screenDims(4);

if referenceSide == 1
    refDims.x = 0.25 * W;
elseif referenceSide == 2
    refDims.x = 0.75 * W;
end
refDims.y = H/4;

displayText = dollarFormatter(settings.game.levels.reference);

Screen('TextSize', settings.device.windowPtr, settings.objects.reference.fontSize);
DrawFormattedText(settings.device.windowPtr, displayText, refDims.x, refDims.y, ...
    settings.default.fontColor);
end

