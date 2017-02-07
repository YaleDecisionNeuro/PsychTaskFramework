function RA_GAINS1(observer);
KbName('KeyNamesWindows');
s = RandStream.create('mt19937ar','seed',sum(100*clock));
RandStream.setGlobalStream(s);
whichScreen = 0;
thisdir = pwd;  % identify current folder
Data.observer=observer;
Data.date=datestr(now,'yyyymmddTHHMMSS');

% Set reference lottery side
if mod(observer,2)==0
    Data.refSide=1;
else
    Data.refSide=2;
end

% make a data directory if necessary
if ~isdir(fullfile(thisdir,'data')) % determine whether input is folder
    disp('Making data directory');
    mkdir('data'); % make new folder
end

% make an observer directory if necessary
datadirname = fullfile(thisdir,'data',num2str(observer));
if ~isdir(datadirname);
    mkdir(datadirname);
end
Data.filename=fullfile('data',num2str(observer),['RA_GAINS_' num2str(observer)]);
Data.stimulus=setParams_LSRA; % setParams_LSRA is a function defined below

% Open window
[Data.stimulus.win Data.stimulus.winrect] = Screen(whichScreen, 'OpenWindow',0); %[handel,window dimensin matrix]
HideCursor(Data.stimulus.win); % hide mouse cursor

Screen('TextFont', Data.stimulus.win, Data.stimulus.fontName);
Data.colorKey={'blue','red'};
Data.stimulus.responseWindowDur=3.5;
Data.stimulus.feedbackDur=.5;
Data.stimulus.lottoDisplayDur=6;

%% Set up a random trial order
% Risk and ambig levels, amount levels
n_repeats=1;
riskyVals=[5,6,7,8,10,12,14,16,19,23,27,31,37,44,52,61,73,86,101,120];
riskyProbs=[.75 .5 .25];
[valsR, probs, repeat]=ndgrid(riskyVals,riskyProbs, 1:n_repeats);
ambigVals=[5,6,7,8,10,12,14,16,19,23,27,31,37,44,52,61,73,86,101,120];
ambigLevels=[.24 .5 .74];
[valsA, ambigs, repeat]=ndgrid(ambigVals,ambigLevels, 1:n_repeats);

% Make equal number of colors within each block
% The numbers in the vectors are trial numbers, they are of the same color . 20 trials total
% Two colors, blue and red
colorIndex1=[1     2     5     6     7    11    14    15    18    20];
colorIndex2=[3     4     8     9    10    12    13    16    17    19];
% Contain a specific pseudorandom [*] order of trial indices; all indices will have the winning amount associated to the same color in a given block
% [*] Pseudorandom rule: no more than three consecutive equal color*win

Data.numTrials = length(valsR(:))+length(valsA(:));
vals=[valsR(:); valsA(:)];
probs=[probs(:); .5*ones(size(ambigs(:)))];
ambigs=[zeros(size(ambigs(:))); ambigs(:)];
% At this point, all of `vals`, `probs` and `ambigs` contain relevant values indexed by `i`

start=1;
for cond=1:6 % start = 1,21, 41, 61, 81, 101
    finish=start+19; % finish = 21,40,60,80,100,120
    assocColorIndex=randperm(2); % shuffle two colors
    % `colors` contains only color assignments for this block, `shufColors` for the entire set of trials
    colors(colorIndex1)=assocColorIndex(1);
    colors(colorIndex2)=assocColorIndex(2);
    shufColors(start:finish)=colors;
    start=start+20;
end

% Randomize trial order
% NOTE: All trial values + parameters are set up, what's generated here is order via `randperm`
paramPrep=[vals probs ambigs shufColors' randperm(length(vals))']; % make the parameters in to matrix. Each row is a trial. The last column is the randomized trial order
expParams=sortrows(paramPrep,5); % present trial in randomized order

% start and final trial number of each block. S1 F1 are used for expParams,
% S2 and F2 are real trial numbers in the task design
S1=[1 31 61 91]; % start of each block
F1=S1+29; % last trial of each block, 30 trials per block
S2=[1 32 63 94]; % start of each block's second trial. The first trial is the catch trial that would be added later
F2=S2+30; % last rial of each block, 31 trials per block
tmpColors=[randperm(2) randperm(2)];
% Per-block ITI lengths
ITIs = [4 * ones(1, (length(vals(:))) / 12), ...
    6 * ones(1, (length(vals(:))) / 12), ...
    8 * ones(1, (length(vals(:))) / 12)];

%Set up stimulus parameters for the first trial in every block. ITI = 10s
%Start of each block is a test trial with $4 victory at 50%, 0 ambiguity, a random color, and ITI of 10 sec
for block=1:4
    Data.vals(S2(block))=4;
    Data.vals(S2(block)+1:F2(block))=expParams(S1(block):F1(block),1);

    Data.probs(S2(block))=.5;
    Data.probs(S2(block)+1:F2(block))=expParams(S1(block):F1(block),2);

    Data.ambigs(S2(block))=0;
    Data.ambigs(S2(block)+1:F2(block))=expParams(S1(block):F1(block),3);

    Data.colors(S2(block))=tmpColors(block);
    Data.colors(S2(block)+1:F2(block))=expParams(S1(block):F1(block),4);

    Data.ITIs(S2(block))=10;
    Data.ITIs(S2(block)+1:F2(block))=ITIs(randperm(length(ITIs)));
end

% write trial parameters into the Data struct
Data.vals=Data.vals';
Data.probs=Data.probs';
Data.ambigs=Data.ambigs';
Data.numTrials=length(Data.vals);

%% Start running trial blocks
blockNum=1;
Screen(Data.stimulus.win, 'FillRect', 1);
Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.lotteryValues);
DrawFormattedText(Data.stimulus.win, ['Block ' num2str(blockNum)], 'center', 'center', Data.stimulus.fontColor);
drawRef(Data)
Screen('flip', Data.stimulus.win);

waitForBackTick;

for trial=1:Data.numTrials/2 %change here to stop after half the trials (LR) The gain trials are separated into two sessions
    Data.trialTime(trial).trialStartTime=datevec(now);
    Data=drawLotto_LSRA(Data,trial); % Draw lottery. The function also controls lottory display time
    Data.trialTime(trial).trialEndTime=datevec(now);
    if mod(trial,31)==0 % After the 31th trial, introduce a pause, wait for input 5 to start the script. Not going through if after other trials
        blockNum=blockNum+1;
        Screen(Data.stimulus.win, 'FillRect',1);
        Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.lotteryValues);
        if blockNum~=3      % 5 to 3 - DE. In other words, if blockNum == 2, continue to next block; if blockNum = 3, first session finished
            DrawFormattedText(Data.stimulus.win, ['Block ' num2str(blockNum)],'center','center',Data.stimulus.fontColor);
        else
            DrawFormattedText(Data.stimulus.win,'Finished First Section','center','center',Data.stimulus.fontColor);
        end
        drawRef(Data)
        Screen('flip',Data.stimulus.win);
        waitForBackTick;
    end
end
%Data=experimentSummary(Data);  %Commented Out Summary from firstsection-DE
eval(sprintf('save %s.mat Data',Data.filename))
Screen('CloseAll') % Close screen and psychtoolbox
end

% Below are functions

% Draw lottery
function Data=drawLotto_LSRA(Data,trial);
eval(sprintf('lotteryValueDims=Data.stimulus.textDims.lotteryValues.Digit%g;',length(num2str(Data.vals(trial)))));
if strcmp(Data.colorKey{Data.colors(trial)},'blue')
    redProb=1-Data.probs(trial);
    blueProb=Data.probs(trial);
elseif strcmp(Data.colorKey{Data.colors(trial)},'red')
    redProb=Data.probs(trial);
    blueProb=1-Data.probs(trial);
end

H=Data.stimulus.winrect(4); % Height
W=Data.stimulus.winrect(3); % Width
Y1=(H-Data.stimulus.lotto.height)/2; % Top of lottery
Y2=Y1+Data.stimulus.lotto.height*redProb; % bottom of red bar
Y3=Y2+Data.stimulus.lotto.height*blueProb; % bottom of blue bar

Y2occ=Y1+Data.stimulus.lotto.height*((1-Data.ambigs(trial))/2); % top of occluder
Y3occ=Y2occ+Data.stimulus.lotto.height*((Data.ambigs(trial))); % bottom of occluder

Screen(Data.stimulus.win, 'FillRect', 1  );
lottoRedDims=[W/2-Data.stimulus.lotto.width/2, Y1, W/2+Data.stimulus.lotto.width/2, Y2]; % dimension of red bar
Screen(Data.stimulus.win,'FillRect',[255 0 0],lottoRedDims);
lottoBlueDims=[W/2-Data.stimulus.lotto.width/2, Y2, W/2+Data.stimulus.lotto.width/2, Y3];
Screen(Data.stimulus.win,'FillRect',[0 0 255],lottoBlueDims);
lottoAmbigDims=[W/2-Data.stimulus.lotto.width/2, Y2occ, W/2+Data.stimulus.lotto.width/2, Y3occ];
Screen(Data.stimulus.win,'FillRect',[127 127 127],lottoAmbigDims);

% Wirite text of value and probability
if strcmp(Data.colorKey{Data.colors(trial)},'blue') % blue trial
    Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.lotteryValues);
    DrawFormattedText(Data.stimulus.win, sprintf('$%s',num2str(Data.vals(trial))),W/2-lotteryValueDims(1)/2, Y3, Data.stimulus.fontColor); % value
    DrawFormattedText(Data.stimulus.win, '$0',W/2-Data.stimulus.textDims.lotteryValues.Digit1(1)/2, Y1-lotteryValueDims(2), Data.stimulus.fontColor); % $0
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

% control lottory display time
elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
while elapsedTime<Data.stimulus.lottoDisplayDur
    elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
end

% Draw green response cue, diameter=20
Screen('FillOval', Data.stimulus.win, [0 255 0], [Data.stimulus.winrect(3)/2-20 Data.stimulus.winrect(4)/2-20 Data.stimulus.winrect(3)/2+20 Data.stimulus.winrect(4)/2+20]);
drawRef(Data)
Screen('flip',Data.stimulus.win);

% Response time
Data.trialTime(trial).respStartTime=datevec(now);
elapsedTime=etime(datevec(now),Data.trialTime(trial).respStartTime);
while elapsedTime<Data.stimulus.responseWindowDur % while the resposne time limit is not reached
    [keyisdown, secs, keyCode, deltaSecs] = KbCheck;
    if keyisdown && (keyCode(KbName('2@')) || keyCode(KbName('1!'))) % 1 or 2 is pressed
        elapsedTime=etime(datevec(now),Data.trialTime(trial).respStartTime); % response time
        break
    end
    elapsedTime=etime(datevec(now),Data.trialTime(trial).respStartTime); % response time again, why?
end

% record response, and specify feedback drawing parameters
if keyisdown && keyCode(KbName('1!'))
    Data.choice(trial)=1;
    Data.rt(trial)=elapsedTime;
    if Data.refSide==2 % if ref is on the right
        yellowDims=[.5*Data.stimulus.winrect(3)/10 -100 .5*Data.stimulus.winrect(3)/10 -100]+[4.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 4.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
        whiteDims=[.5*Data.stimulus.winrect(3)/10 -100 .5*Data.stimulus.winrect(3)/10 -100]+[5.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 5.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
    else
        yellowDims=[-.5*Data.stimulus.winrect(3)/10 -100 -.5*Data.stimulus.winrect(3)/10 -100]+[4.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 4.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
        whiteDims=[-.5*Data.stimulus.winrect(3)/10 -100 -.5*Data.stimulus.winrect(3)/10 -100]+[5.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 5.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
    end
    yellowColor=[255 255 0]; % yellow
elseif keyisdown && keyCode(KbName('2@'))
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
    yellowColor=[255 255 255]; % white
    if Data.refSide==2
        whiteDims=[.5*Data.stimulus.winrect(3)/10 -100 .5*Data.stimulus.winrect(3)/10 -100]+[4.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 4.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
        yellowDims=[.5*Data.stimulus.winrect(3)/10 -100 .5*Data.stimulus.winrect(3)/10 -100]+[5.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 5.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
    else
        whiteDims=[-.5*Data.stimulus.winrect(3)/10 -100 -.5*Data.stimulus.winrect(3)/10 -100]+[4.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 4.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
        yellowDims=[-.5*Data.stimulus.winrect(3)/10 -100 -.5*Data.stimulus.winrect(3)/10 -100]+[5.5*Data.stimulus.winrect(3)/10-20 Data.stimulus.winrect(4)/2-20 5.5*Data.stimulus.winrect(3)/10+20 Data.stimulus.winrect(4)/2+20];
    end
end

% draw response feedback. On the same side of the reference lottery.
Screen(Data.stimulus.win,'FillRect',yellowColor,yellowDims);
Screen(Data.stimulus.win,'FillRect',[255 255 255],whiteDims);
drawRef(Data)
Screen('flip',Data.stimulus.win);

% control feedback display time
Data.trialTime(trial).feedbackStartTime=datevec(now);
elapsedTime=etime(datevec(now),Data.trialTime(trial).feedbackStartTime);
while elapsedTime<Data.stimulus.feedbackDur
    elapsedTime=etime(datevec(now),Data.trialTime(trial).feedbackStartTime);
end

% draw ITI cue
eval(sprintf('save %s.mat Data', Data.filename))
Screen('FillOval', Data.stimulus.win, [255 255 255], [Data.stimulus.winrect(3)/2-20 Data.stimulus.winrect(4)/2-20 Data.stimulus.winrect(3)/2+20 Data.stimulus.winrect(4)/2+20]);
drawRef(Data)
Screen('flip',Data.stimulus.win);

% control ITI time

Data.trialTime(trial).ITIStartTime=datevec(now);
elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
while elapsedTime<Data.stimulus.lottoDisplayDur+Data.stimulus.responseWindowDur+Data.stimulus.feedbackDur+Data.ITIs(trial)
    elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
end
end

% set text and rectangle parameters
function params = setParams_LSRA;
params.fontName='Ariel';
params.fontColor=[255 255 255];
% font of probability inside the rectangle
params.fontSize.probabilities=20;
params.textDims.probabilities=[31 30];
params.fontSize.refProbabilities=10;
params.textDims.refProbabilities=[12 19];
% font of lottery values
% textDims, [width height]
params.fontSize.lotteryValues=42;
params.textDims.lotteryValues.Digit1=[64 64];
params.textDims.lotteryValues.Digit2=[92 64];
params.textDims.lotteryValues.Digit3=[120 64];
%font of reference
params.fontSize.refValues=42;
params.textDims.refValues.Digit1=[31 30];
params.textDims.refValues.Digit2=[42 30];
% rectangle size
params.lotto.width=150;
params.lotto.height=300;
params.ref.width=50;
params.ref.height=100;
end

% draw the reference $5
function drawRef(Data)
H=Data.stimulus.winrect(4);
W=Data.stimulus.winrect(3);
if Data.refSide==1 % reference on the left
    refDims.x=W/4;
elseif Data.refSide==2 % reference on the right
    refDims.x=3*(W/4);
end
refDims.y=H/4;
Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.refValues);
DrawFormattedText(Data.stimulus.win, '$5',refDims.x, refDims.y, Data.stimulus.fontColor);
end

% wait for input of #5
function waitForBackTick;
while 1
    [keyisdown, secs, keyCode, deltaSecs] = KbCheck;
    if keyisdown && keyCode(KbName('5%'))==1
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
            Data.Summary(block,trial).blueValue=sprintf('-$%s',num2str(Data.vals(t)));
            Data.Summary(block,trial).redValue='$0';
        elseif Data.colors(t)==2
            Data.Summary(block,trial).redValue=sprintf('-$%s',num2str(Data.vals(t)));
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
