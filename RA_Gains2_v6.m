%Remember to set correct path for .mat load file (~line 95)

function RA_Gains2_v7(observer);
% Change from v6 to v7:
%     - Use Screen('DrawText') instead of DrawFormattedText() becaue the latter
%       as some offset in estimating text position
%     - save the data when every trial is finished, instead of saving it
%       when the 2 blocks are finished
%     - after loading the data from first session, re-create task
%       parameters in case that a different computer is used for the second
%       session
%     - load the data by detecting the current directoru, not manually
%       input the directory

KbName('KeyNamesWindows');
s = RandStream.create('mt19937ar','seed',sum(100*clock));
RandStream.setGlobalStream(s);
whichScreen = 0;        %% 1 to 0
thisdir = pwd;

% make a data directory if necessary
if ~isdir(fullfile(thisdir,'data'))
    disp('Making data directory');
    mkdir('data');
end

% make an observer directory if necessary
datadirname = fullfile(thisdir,'data',num2str(observer));
if ~isdir(datadirname);
    mkdir(datadirname);
end

%load block 1 and 2 .mat file
% Data.filename=fullfile('data',num2str(observer),['RA_GAINS_' num2str(observer)]);
load([thisdir '\data\' num2str(observer) '\RA_GAINS_' num2str(observer)]); 

Data.observer=observer;
Data.date=datestr(now,'yyyymmddTHHMMSS');
if mod(observer,2)==0
    Data.refSide=1;
else
    Data.refSide=2;
end

Data.stimulus=setParams_LSRA;
[Data.stimulus.win Data.stimulus.winrect] = Screen(whichScreen, 'OpenWindow',0);
HideCursor(Data.stimulus.win);

Screen('TextFont', Data.stimulus.win, Data.stimulus.fontName);
Data.colorKey={'blue','red'};
Data.stimulus.responseWindowDur=3.5;
Data.stimulus.feedbackDur=.5;
Data.stimulus.lottoDisplayDur=6;


blockNum=3; %this is second session; starting from block 3 (LR)
Screen(Data.stimulus.win, 'FillRect',1);
Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.lotteryValues);
DrawFormattedText(Data.stimulus.win, ['Block ' num2str(blockNum)],'center','center',Data.stimulus.fontColor);
drawRef(Data)
Screen('flip',Data.stimulus.win);
waitForBackTick;
Data.stimulus.textDims.probabilities = getTextDims(Data.stimulus.win,'50', Data.stimulus.fontSize.probabilities);% get the text dimensons for probability
for trial=Data.numTrials/2 + 1:Data.numTrials %change here to start after half the trials (LR)
    Data.trialTime(trial).trialStartTime=datevec(now);
    Data=drawLotto_LSRA(Data,trial);
    Data.trialTime(trial).trialEndTime=datevec(now);
    eval(sprintf('save %s.mat Data',Data.filename))
    if mod(trial,31)==0
        blockNum=blockNum+1;
        Screen(Data.stimulus.win, 'FillRect',1);
        Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.lotteryValues);
        if blockNum~=5
            DrawFormattedText(Data.stimulus.win, ['Block ' num2str(blockNum)],'center','center',Data.stimulus.fontColor);
        else
            DrawFormattedText(Data.stimulus.win,'Experiment Finished','center','center',Data.stimulus.fontColor);
        end
        drawRef(Data)
        Screen('flip',Data.stimulus.win);
        waitForBackTick;
    end
end
Data=experimentSummary(Data);
eval(sprintf('save %s.mat Data',Data.filename))
Screen('CloseAll')
end

%%
function Data=drawLotto_LSRA(Data,trial)
%eval(sprintf('lotteryValueDims=Data.stimulus.textDims.lotteryValues.Digit%g;',length(num2str(Data.vals(trial)))));% text dimension depending on how long the text is
if strcmp(Data.colorKey{Data.colors(trial)},'blue')
    redProb=1-Data.probs(trial);
    blueProb=Data.probs(trial);
elseif strcmp(Data.colorKey{Data.colors(trial)},'red')
    redProb=Data.probs(trial);
    blueProb=1-Data.probs(trial);
end

H=Data.stimulus.winrect(4);
W=Data.stimulus.winrect(3);
Y1=(H-Data.stimulus.lotto.height)/2; % top of red 
Y2=Y1+Data.stimulus.lotto.height*redProb; % top of blue
Y3=Y2+Data.stimulus.lotto.height*blueProb; % bottom of blue

Y2occ=Y1+Data.stimulus.lotto.height*((1-Data.ambigs(trial))/2); % top of occ
Y3occ=Y2occ+Data.stimulus.lotto.height*((Data.ambigs(trial))); % bottom of occ

Screen(Data.stimulus.win, 'FillRect', 1  );
lottoRedDims=[W/2-Data.stimulus.lotto.width/2, Y1, W/2+Data.stimulus.lotto.width/2, Y2];
Screen(Data.stimulus.win,'FillRect',[255 0 0],lottoRedDims);
lottoBlueDims=[W/2-Data.stimulus.lotto.width/2, Y2, W/2+Data.stimulus.lotto.width/2, Y3];
Screen(Data.stimulus.win,'FillRect',[0 0 255],lottoBlueDims);
lottoAmbigDims=[W/2-Data.stimulus.lotto.width/2, Y2occ, W/2+Data.stimulus.lotto.width/2, Y3occ];
Screen(Data.stimulus.win,'FillRect',[127 127 127],lottoAmbigDims);
if strcmp(Data.colorKey{Data.colors(trial)},'blue')
    Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.lotteryValues);
    lotteryValueDims = getTextDims(Data.stimulus.win, sprintf('$%s',num2str(Data.vals(trial))),Data.stimulus.fontSize.lotteryValues);
    Screen('DrawText',Data.stimulus.win, sprintf('$%s',num2str(Data.vals(trial))),W/2-lotteryValueDims(1)/2, Y3, Data.stimulus.fontColor);
    zeroValueDims = getTextDims(Data.stimulus.win,'$0',Data.stimulus.fontSize.lotteryValues);
    Screen('DrawText',Data.stimulus.win, '$0',W/2-zeroValueDims(1)/2, Y1-zeroValueDims(2), Data.stimulus.fontColor);
    Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.probabilities);
    if Data.ambigs(trial)==0
        Screen('DrawText',Data.stimulus.win, sprintf('%s',num2str(blueProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y2+(Y3-Y2)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        Screen('DrawText',Data.stimulus.win, sprintf('%s',num2str(redProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
    else
        Screen('DrawText',Data.stimulus.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y3occ+(Y3-Y3occ)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        Screen('DrawText',Data.stimulus.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2occ-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
    end
elseif strcmp(Data.colorKey{Data.colors(trial)},'red')
    Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.lotteryValues);
    lotteryValueDims = getTextDims(Data.stimulus.win, sprintf('$%s',num2str(Data.vals(trial))),Data.stimulus.fontSize.lotteryValues);
    Screen('DrawText',Data.stimulus.win, sprintf('$%s',num2str(Data.vals(trial))),W/2-lotteryValueDims(1)/2, Y1-lotteryValueDims(2), Data.stimulus.fontColor);
    zeroValueDims = getTextDims(Data.stimulus.win,'$0',Data.stimulus.fontSize.lotteryValues);
    Screen('DrawText',Data.stimulus.win, '$0',W/2-zeroValueDims(1)/2, Y3, Data.stimulus.fontColor);
    Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.probabilities);
    if Data.ambigs(trial)==0
        Screen('DrawText',Data.stimulus.win, sprintf('%s',num2str(blueProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y2+(Y3-Y2)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        Screen('DrawText',Data.stimulus.win, sprintf('%s',num2str(redProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
    else
        Screen('DrawText',Data.stimulus.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y3occ+(Y3-Y3occ)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        Screen('DrawText',Data.stimulus.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2occ-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
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

%%
function textDims = getTextDims(win,myText,textSize)
Screen('TextSize',win,textSize);
textRect = Screen ('TextBounds',win,myText);
textDims = [textRect(3) textRect(4)]; % text width and height
end
%%
function params = setParams_LSRA;
params.fontName='Ariel';
params.fontColor=[255 255 255];
params.fontSize.probabilities=20;
% params.textDims.probabilities=[31 30]; % use getTextDims in the very beginning
params.fontSize.refProbabilities=10; % is it used?
% params.textDims.refProbabilities=[12 19];

params.fontSize.lotteryValues=42;
%params.textDims.lotteryValues.Digit1=[64 64];
%params.textDims.lotteryValues.Digit2=[92 64];
%params.textDims.lotteryValues.Digit3=[120 64];

params.fontSize.refValues=42;
% params.textDims.refValues.Digit1=[31 30];
% params.textDims.refValues.Digit2=[42 30];

params.lotto.width=150;
params.lotto.height=300;
% params.ref.width=50; % is it used?
% params.ref.height=100; % is it used?
params.occ.width = 180;
end

%%
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
% refTextDims = gettextDims(Data.stimulus.win, '$5', Data.stimulus.fontSize.refValues);
Screen('DrawText',Data.stimulus.win, '$5',refDims.x, refDims.y, Data.stimulus.fontColor);
end
%%
function waitForBackTick;
while 1
    [keyisdown, secs, keycode, deltaSecs] = KbCheck;
    if keyisdown && keycode(KbName('5%'))==1 %change here? (LR)
        break
    end
end
end

%Broke DataSummary into Block 1&2 Gains/Block 3&4 Loss
function Data=experimentSummary(Data)
block=1;
trial=1;
for t=1:Data.numTrials
    if block<3;
        if Data.choice(t)==1 && Data.refSide==2
            Data.Summary(block,trial).choice='Lottery';
        elseif Data.choice(t)==2 && Data.refSide==1
            Data.Summary(block,trial).choice='Lottery';
        elseif Data.choice(t)==0
            Data.Summary(block,trial).choice='None';
        else
            Data.Summary(block,trial).choice='Reference';
        end

        if Data.probs(t)==.5
            Data.Summary(block,trial).bagNumber=4;
        elseif Data.probs(t)==.25 && Data.colors(t)==1
            Data.Summary(block,trial).bagNumber=3;
        elseif Data.probs(t)==.25 && Data.colors(t)==2
            Data.Summary(block,trial).bagNumber=5;
        elseif Data.probs(t)==.75 && Data.colors(t)==1
            Data.Summary(block,trial).bagNumber=5;
        elseif Data.probs(t)==.75 && Data.colors(t)==2
            Data.Summary(block,trial).bagNumber=3;
        end

        if Data.ambigs(t)==.24
            Data.Summary(block,trial).bagNumber=10;
        elseif Data.ambigs(t)==.5
            Data.Summary(block,trial).bagNumber=11;
        elseif Data.ambigs(t)==.74
            Data.Summary(block,trial).bagNumber=12;
        end

        if Data.colors(t)==1
            Data.Summary(block,trial).blueValue=sprintf('$%s',num2str(Data.vals(t)));
            Data.Summary(block,trial).redValue='$0';
        elseif Data.colors(t)==2
            Data.Summary(block,trial).redValue=sprintf('$%s',num2str(Data.vals(t)));
            Data.Summary(block,trial).blueValue='$0';
        end
    else
        if Data.choice(t)==1 && Data.refSide==2
            Data.Summary(block,trial).choice='Lottery';
        elseif Data.choice(t)==2 && Data.refSide==1
            Data.Summary(block,trial).choice='Lottery';
        elseif Data.choice(t)==0
            Data.Summary(block,trial).choice='None';
        else
            Data.Summary(block,trial).choice='Reference';
        end

        if Data.probs(t)==.5
            Data.Summary(block,trial).bagNumber=4;
        elseif Data.probs(t)==.25 && Data.colors(t)==1
            Data.Summary(block,trial).bagNumber=3;
        elseif Data.probs(t)==.25 && Data.colors(t)==2
            Data.Summary(block,trial).bagNumber=5;
        elseif Data.probs(t)==.75 && Data.colors(t)==1
            Data.Summary(block,trial).bagNumber=5;
        elseif Data.probs(t)==.75 && Data.colors(t)==2
            Data.Summary(block,trial).bagNumber=3;
        end

        if Data.ambigs(t)==.24
            Data.Summary(block,trial).bagNumber=10;
        elseif Data.ambigs(t)==.5
            Data.Summary(block,trial).bagNumber=11;
        elseif Data.ambigs(t)==.74
            Data.Summary(block,trial).bagNumber=12;
        end

        if Data.colors(t)==1
            Data.Summary(block,trial).blueValue=sprintf('$%s',num2str(Data.vals(t)));
            Data.Summary(block,trial).redValue='$0';
        elseif Data.colors(t)==2
            Data.Summary(block,trial).redValue=sprintf('$%s',num2str(Data.vals(t)));
            Data.Summary(block,trial).blueValue='$0';
        end
    end
    if trial ~=31
        trial=trial+1;
    else
        trial=1;
        block=block+1;
    end
end
end