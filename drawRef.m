function drawRef(Data)
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

