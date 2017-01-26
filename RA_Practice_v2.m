function RA_Practice_v2(observer);
KbName('KeyNamesWindows');
s = RandStream.create('mt19937ar','seed',sum(100*clock));
RandStream.setGlobalStream(s);
whichScreen = 0;
thisdir = pwd;
Data.observer=observer;
Data.date=datestr(now,'yyyymmddTHHMMSS');
if mod(observer,2)==0
    Data.refSide=1;
else
    Data.refSide=2;
end

Data.filename=fullfile('data',num2str(observer),['RA_GAINS_' num2str(observer)]);
Data.stimulus=setParams_LSRA;
[Data.stimulus.win Data.stimulus.winrect] = Screen(whichScreen, 'OpenWindow',0);
HideCursor(Data.stimulus.win);

Screen('TextFont', Data.stimulus.win, Data.stimulus.fontName);
Data.colorKey={'blue','red'};
Data.stimulus.responseWindowDur=3.5;
Data.stimulus.feedbackDur=.5;
Data.stimulus.lottoDisplayDur=6;

Data.vals= [5 16 19 111 72 9]';
Data.probs= [.5 .5 .25 .5 .25 .5]';
Data.ambigs= [0 .24 0 .74 0 .24]';
Data.numTrials=length(Data.vals);
Data.ITIs = [8 4 8 6 4 8];
Data.colors = [2 1 2 1 2 2];

blockNum=1;
Screen(Data.stimulus.win, 'FillRect',1);
Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.lotteryValues);
DrawFormattedText(Data.stimulus.win, ['Block ' num2str(blockNum)],'center','center',Data.stimulus.fontColor);
drawRef(Data)
Screen('flip',Data.stimulus.win);
waitForBackTick;
for trial=1:Data.numTrials
    Data.trialTime(trial).trialStartTime=datevec(now);
    Data=drawLotto_LSRA(Data,trial);
    Data.trialTime(trial).trialEndTime=datevec(now);
    if mod(trial,6)==0
        blockNum=blockNum+1;
        Screen(Data.stimulus.win, 'FillRect',1);
        Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.lotteryValues);
        if blockNum~=2      % 5 to 2 - DE
            DrawFormattedText(Data.stimulus.win, ['Block ' num2str(blockNum)],'center','center',Data.stimulus.fontColor);
        else
            DrawFormattedText(Data.stimulus.win,'Finished Practice','center','center',Data.stimulus.fontColor);
        end
        drawRef(Data)
        Screen('flip',Data.stimulus.win);
        waitForBackTick;
    end
end
Screen('CloseAll')
end
function Data=drawLotto_LSRA(Data,trial)
eval(sprintf('lotteryValueDims=Data.stimulus.textDims.lotteryValues.Digit%g;',length(num2str(Data.vals(trial)))));
if strcmp(Data.colorKey{Data.colors(trial)},'blue')
    redProb=1-Data.probs(trial);
    blueProb=Data.probs(trial);
elseif strcmp(Data.colorKey{Data.colors(trial)},'red')
    redProb=Data.probs(trial);
    blueProb=1-Data.probs(trial);
end

H=Data.stimulus.winrect(4);
W=Data.stimulus.winrect(3);
Y1=(H-Data.stimulus.lotto.height)/2;
Y2=Y1+Data.stimulus.lotto.height*redProb;
Y3=Y2+Data.stimulus.lotto.height*blueProb;

Y2occ=Y1+Data.stimulus.lotto.height*((1-Data.ambigs(trial))/2);
Y3occ=Y2occ+Data.stimulus.lotto.height*((Data.ambigs(trial)));

Screen(Data.stimulus.win, 'FillRect', 1  );
lottoRedDims=[W/2-Data.stimulus.lotto.width/2, Y1, W/2+Data.stimulus.lotto.width/2, Y2];
Screen(Data.stimulus.win,'FillRect',[255 0 0],lottoRedDims);
lottoBlueDims=[W/2-Data.stimulus.lotto.width/2, Y2, W/2+Data.stimulus.lotto.width/2, Y3];
Screen(Data.stimulus.win,'FillRect',[0 0 255],lottoBlueDims);
lottoAmbigDims=[W/2-Data.stimulus.lotto.width/2, Y2occ, W/2+Data.stimulus.lotto.width/2, Y3occ];
Screen(Data.stimulus.win,'FillRect',[127 127 127],lottoAmbigDims);
if strcmp(Data.colorKey{Data.colors(trial)},'blue')
    Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.lotteryValues);
    DrawFormattedText(Data.stimulus.win, sprintf('$%s',num2str(Data.vals(trial))),W/2-lotteryValueDims(1)/2, Y3, Data.stimulus.fontColor);
    DrawFormattedText(Data.stimulus.win, '$0',W/2-Data.stimulus.textDims.lotteryValues.Digit1(1)/2, Y1-lotteryValueDims(2), Data.stimulus.fontColor);
    Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.probabilities);
    if Data.ambigs(trial)==0
        DrawFormattedText(Data.stimulus.win, sprintf('%s',num2str(blueProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y2+(Y3-Y2)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        DrawFormattedText(Data.stimulus.win, sprintf('%s',num2str(redProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
    else
        DrawFormattedText(Data.stimulus.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y3occ+(Y3-Y3occ)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        DrawFormattedText(Data.stimulus.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2occ-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
    end
elseif strcmp(Data.colorKey{Data.colors(trial)},'red')
    Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.lotteryValues);
    DrawFormattedText(Data.stimulus.win, sprintf('$%s',num2str(Data.vals(trial))),W/2-lotteryValueDims(1)/2, Y1-lotteryValueDims(2), Data.stimulus.fontColor);
    DrawFormattedText(Data.stimulus.win, '$0',W/2-Data.stimulus.textDims.lotteryValues.Digit1(1)/2, Y3, Data.stimulus.fontColor);
    Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.probabilities);
    if Data.ambigs(trial)==0
        DrawFormattedText(Data.stimulus.win, sprintf('%s',num2str(blueProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y2+(Y3-Y2)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        DrawFormattedText(Data.stimulus.win, sprintf('%s',num2str(redProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
    else
        DrawFormattedText(Data.stimulus.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y3occ+(Y3-Y3occ)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        DrawFormattedText(Data.stimulus.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2occ-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
    end
end

drawRef(Data)
Screen('flip',Data.stimulus.win);

elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
while elapsedTime<Data.stimulus.lottoDisplayDur
    elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
end

Screen('FillOval', Data.stimulus.win, [0 255 0], [Data.stimulus.winrect(3)/2-20 Data.stimulus.winrect(4)/2-20 Data.stimulus.winrect(3)/2+20 Data.stimulus.winrect(4)/2+20]);
drawRef(Data)
Screen('flip',Data.stimulus.win);
Data.trialTime(trial).respStartTime=datevec(now);
elapsedTime=etime(datevec(now),Data.trialTime(trial).respStartTime);
while elapsedTime<Data.stimulus.responseWindowDur
    [keyisdown, secs, keycode, deltaSecs] = KbCheck;
    if keyisdown && (keycode(KbName('2@')) || keycode(KbName('1!')))
        elapsedTime=etime(datevec(now),Data.trialTime(trial).respStartTime);
        break
    end
    elapsedTime=etime(datevec(now),Data.trialTime(trial).respStartTime);
end

if keyisdown && keycode(KbName('1!'))            %% Reversed keys '1' and '2' - DE
    Data.choice(trial)=1;
    Data.rt(trial)=elapsedTime;
    if Data.refSide==2
        yellowDims=[.5*Data.stimulus.winrect(3)/10 -100 .5*Data.stimulus.winrect(3)/10 -100]+[4.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 4.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
        whiteDims=[.5*Data.stimulus.winrect(3)/10 -100 .5*Data.stimulus.winrect(3)/10 -100]+[5.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 5.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
    else
        yellowDims=[-.5*Data.stimulus.winrect(3)/10 -100 -.5*Data.stimulus.winrect(3)/10 -100]+[4.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 4.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
        whiteDims=[-.5*Data.stimulus.winrect(3)/10 -100 -.5*Data.stimulus.winrect(3)/10 -100]+[5.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 5.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
    end
    yellowColor=[255 255 0];
elseif keyisdown && keycode(KbName('2@'))        %% Reversed keys '2' and '1' - DE
    Data.choice(trial)=2;
    Data.rt(trial)=elapsedTime;
    if Data.refSide==2
        whiteDims=[.5*Data.stimulus.winrect(3)/10 -100 .5*Data.stimulus.winrect(3)/10 -100]+[4.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 4.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
        yellowDims=[.5*Data.stimulus.winrect(3)/10 -100 .5*Data.stimulus.winrect(3)/10 -100]+[5.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 5.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
    else
        whiteDims=[-.5*Data.stimulus.winrect(3)/10 -100 -.5*Data.stimulus.winrect(3)/10 -100]+[4.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 4.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
        yellowDims=[-.5*Data.stimulus.winrect(3)/10 -100 -.5*Data.stimulus.winrect(3)/10 -100]+[5.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 5.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
    end
    Data.rt(trial)=elapsedTime;
    yellowColor=[255 255 0];
else
    Data.choice(trial)=0;
    Data.rt(trial)=NaN;
    yellowColor=[255 255 255];
    if Data.refSide==2
        whiteDims=[.5*Data.stimulus.winrect(3)/10 -100 .5*Data.stimulus.winrect(3)/10 -100]+[4.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 4.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
        yellowDims=[.5*Data.stimulus.winrect(3)/10 -100 .5*Data.stimulus.winrect(3)/10 -100]+[5.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 5.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
    else
        whiteDims=[-.5*Data.stimulus.winrect(3)/10 -100 -.5*Data.stimulus.winrect(3)/10 -100]+[4.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 4.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
        yellowDims=[-.5*Data.stimulus.winrect(3)/10 -100 -.5*Data.stimulus.winrect(3)/10 -100]+[5.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 5.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
    end
end
Screen(Data.stimulus.win,'FillRect',yellowColor,yellowDims);
Screen(Data.stimulus.win,'FillRect',[255 255 255],whiteDims);
drawRef(Data)
Screen('flip',Data.stimulus.win);

Data.trialTime(trial).feedbackStartTime=datevec(now);
elapsedTime=etime(datevec(now),Data.trialTime(trial).feedbackStartTime);
while elapsedTime<Data.stimulus.feedbackDur
    elapsedTime=etime(datevec(now),Data.trialTime(trial).feedbackStartTime);
end

Screen('FillOval', Data.stimulus.win, [255 255 255], [Data.stimulus.winrect(3)/2-20 Data.stimulus.winrect(4)/2-20 Data.stimulus.winrect(3)/2+20 Data.stimulus.winrect(4)/2+20]);
drawRef(Data)
Screen('flip',Data.stimulus.win);

Data.trialTime(trial).ITIStartTime=datevec(now);
elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
while elapsedTime<Data.stimulus.lottoDisplayDur+Data.stimulus.responseWindowDur+Data.stimulus.feedbackDur+Data.ITIs(trial)
    elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
end
end
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
end
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
function waitForBackTick;
while 1
    [keyisdown, secs, keycode, deltaSecs] = KbCheck;
    if keyisdown && keycode(KbName('5%'))==1
        break
    end
end
end
