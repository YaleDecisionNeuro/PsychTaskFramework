% Same across calls
function params = setParams_LSRA;
params.fontName='Ariel';
params.fontColor=[255 255 255];
params.fontSize.probabilities=20;
params.textDims.probabilities=[31 30];
params.fontSize.refProbabilities=10;
params.textDims.refProbabilities=[12 19];

params.fontSize.lotteryValues=42;
params.textDims.lotteryValues.Digit1=[64 64];
params.textDims.lotteryValues.Digit2=[92 64];
params.textDims.lotteryValues.Digit3=[120 64];

params.fontSize.refValues=42;
params.textDims.refValues.Digit1=[31 30];
params.textDims.refValues.Digit2=[42 30];

params.lotto.width=150;
params.lotto.height=300;
params.ref.width=50;
params.ref.height=100;

params.colors_prob = [255 0 0; 0 0 255]; % RGB values
params.color_ambig = [127 127 127];

params.color_background = [0 0 0];
end
