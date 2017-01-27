function drawRef(Data)
% Draws the stable reference value on screen
% TODO: Separate `Data` into `settings` and ... individual settings?
% Inputs: screen size (`.winrect`), side to draw on (`refSide`),
%   screen ID? (`.win`), font size
% TODO: $5 should be drawn from settings
H=Data.stimulus.winrect(4);
W=Data.stimulus.winrect(3);
if Data.refSide==1
    refDims.x=W/4;
elseif Data.refSide==2
    refDims.x=3*(W/4);
end
refDims.y=H/4;
Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.refValues);
DrawFormattedText(Data.stimulus.win, '$5',refDims.x, refDims.y, Data.stimulus.fontColor);
end

