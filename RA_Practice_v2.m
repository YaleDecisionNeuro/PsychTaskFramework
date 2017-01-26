function RA_Practice_v2(observer);
%% Setup
% Set keys to Windows keys (script still works on OSX)
% TODO: Condition on system detection? Or, abstract settings into a file explicitly labeled as such, and referenced in globals?
KbName('KeyNamesWindows');

% Set random generator
s = RandStream.create('mt19937ar', 'seed', sum(100*clock));
RandStream.setGlobalStream(s);

% Remember current directory (unused)
% TODO: Align with current script location `mfilename('fullpath')`
thisdir = pwd;
Data.filename = fullfile('data', num2str(observer), ['RA_GAINS_' num2str(observer)]);

% Save participant ID + date
% TODO: Prompt for correctness before launching PTB?
Data.observer = observer;
Data.date = datestr(now,'yyyymmddTHHMMSS');

% Randomize the side of sure choice by participant ID
% TODO: Add more descriptive variable than refSide? (Need to remain backwards-compatible.)
if mod(observer, 2) == 0
    Data.refSide = 1;
else
    Data.refSide = 2;
end

%% Window settings
whichScreen = 0; % windowPtr?
Data.stimulus = setParams_LSRA();

% Open a window
[Data.stimulus.win, Data.stimulus.winrect] = Screen(whichScreen, 'OpenWindow', 0);
HideCursor(Data.stimulus.win);
Screen('TextFont', Data.stimulus.win, Data.stimulus.fontName);

% Properties TODO: Should this be inherited from settings rather than hardcoded?
% Properties of lottery display
Data.colorKey = {'blue', 'red'}; % Unordered, and is this useful?
Data.stimulus.responseWindowDur = 3.5;
Data.stimulus.feedbackDur = .5;
Data.stimulus.lottoDisplayDur = 6;

% Properties of lottery choices
Data.vals = [5 16 19 111 72 9]';
Data.probs = [.5 .5 .25 .5 .25 .5]';
Data.ambigs = [0 .24 0 .74 0 .24]';
Data.numTrials = length(Data.vals);
Data.ITIs  = [8 4 8 6 4 8];
Data.colors = [2 1 2 1 2 2];

Screen(Data.stimulus.win, 'FillRect', 1); % Clear window?

%% Experiment begins!
blockNum = 1;

Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.lotteryValues);
DrawFormattedText(Data.stimulus.win, ['Block ' num2str(blockNum)], ...
  'center', 'center', Data.stimulus.fontColor); % Block 1 in center
drawRef(Data) % Draw reference value
Screen('flip', Data.stimulus.win); % Display screen?
waitForBackTick; % Wait for 5 or @ to hit before proceeding

for trial = 1:Data.numTrials
    Data.trialTime(trial).trialStartTime = datevec(now);
    Data = drawLotto_LSRA(Data, trial); % Draw lottery
    Data.trialTime(trial).trialEndTime = datevec(now);

    if mod(trial, 6) == 0 % Every six trials, start new block (possibly leftover from E-Prime?)
        blockNum = blockNum + 1;
        Screen(Data.stimulus.win, 'FillRect', 1);
        Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.lotteryValues);
        if blockNum ~= 2      % 5 to 2 - DE
            % Possibly a leftover from a for-loop that displayed more practice values?
            DrawFormattedText(Data.stimulus.win, ['Block ' num2str(blockNum)], ...
              'center', 'center', Data.stimulus.fontColor);
            drawRef(Data)
        else
            DrawFormattedText(Data.stimulus.win, 'Finished Practice', ...
              'center', 'center', Data.stimulus.fontColor);
        end
        %drawRef(Data) % Don't display for practice finishing

        % Display screen and with for press of 5 to terminate
        Screen('flip', Data.stimulus.win);
        waitForBackTick;
    end
end
Screen('CloseAll') % Turn screen off
end

function Data=drawLotto_LSRA(Data,trial)

% Dimensions for n digits in the lottery payoff
digit_field = sprintf('Digit%d', length(num2str(Data.vals(trial))));
lotteryValueDims = Data.stimulus.textDims.lotteryValues.(digit_field);

% Determine probabilities to associate with colors
if strcmp(Data.colorKey{Data.colors(trial)}, 'blue')
    redProb = 1 - Data.probs(trial);
    blueProb = Data.probs(trial);
elseif strcmp(Data.colorKey{Data.colors(trial)}, 'red')
    redProb = Data.probs(trial);
    blueProb = 1 - Data.probs(trial);
end

% TODO: Understand + refactor the following section
H = Data.stimulus.winrect(4); % height
W = Data.stimulus.winrect(3); % width
Y1 = (H-Data.stimulus.lotto.height)/2;
Y2 = Y1+Data.stimulus.lotto.height*redProb;
Y3 = Y2+Data.stimulus.lotto.height*blueProb;

Y2occ = Y1+Data.stimulus.lotto.height*((1-Data.ambigs(trial))/2);
Y3occ = Y2occ+Data.stimulus.lotto.height*((Data.ambigs(trial)));

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

elapsedTime = etime(datevec(now),Data.trialTime(trial).trialStartTime);
while elapsedTime < Data.stimulus.lottoDisplayDur
    elapsedTime = etime(datevec(now),Data.trialTime(trial).trialStartTime);
end
% End TODO

%% Display green dot, signifying the beginning of response time
Screen('FillOval', Data.stimulus.win, [0 255 0], [Data.stimulus.winrect(3)/2-20 Data.stimulus.winrect(4)/2-20 Data.stimulus.winrect(3)/2+20 Data.stimulus.winrect(4)/2+20]);
drawRef(Data)
Screen('flip',Data.stimulus.win);
Data.trialTime(trial).respStartTime = datevec(now);
elapsedTime = etime(datevec(now),Data.trialTime(trial).respStartTime);
while elapsedTime<Data.stimulus.responseWindowDur
    [keyisdown, secs, keycode, deltaSecs] = KbCheck;
    if keyisdown && (keycode(KbName('2@')) || keycode(KbName('1!')))
        elapsedTime = etime(datevec(now),Data.trialTime(trial).respStartTime);
        break
    end
    elapsedTime = etime(datevec(now),Data.trialTime(trial).respStartTime);
end


%% Base for computation of feedback box positions
% left-top-right-bottom border in px
coord_shift = [.5 * Data.stimulus.winrect(3) / 10, -100, ...
               .5 * Data.stimulus.winrect(3) / 10, -100]; % 51 -100 51 -100

left_coord = [4.5 * Data.stimulus.winrect(3) / 10 - 20, ...
              Data.stimulus.winrect(4) / 2 - 20];
left_coord = [left_coord, left_coord + 40]; % 441 364 481 404

right_coord  = [5.5 * Data.stimulus.winrect(3) / 10 - 20, ...
                Data.stimulus.winrect(4) / 2 - 20];
right_coord  = [right_coord, right_coord + 40]; % 543 364 583 404
% So, same height, but further to the right

% Translate into positions
leftPos  = coord_shift + left_coord;
rightPos = coord_shift + right_coord;

% Do the constant translation on refSide == 1
if Data.refSide == 1
  posShift = [-1 * Data.stimulus.winrect(3) / 10, 0,
              -1 * Data.stimulus.winrect(3) / 10, 0]; % -102 0 -102 0
  leftPos = leftPos + posShift;
  rightPos = rightPos + posShift;
end

%% Assign coords
% NOTE: yellowDims and whiteDims computes the coordinates for which feedback and non-feedback rectangles display
% NOTE: yellowColor defines whether the feedback square will be yellow (on press) or white (on non-press)

% TODO: If a function can translate choice + refSide into a lottery choice,
% this could flag stochastic dominance violations as they happen

if keyisdown && keycode(KbName('1!'))            %% Reversed keys '1' and '2' - DE
    Data.choice(trial) = 1;
    Data.rt(trial) = elapsedTime;

    yellowDims = leftPos;
    whiteDims  = rightPos;

    yellowColor = [255 255 0];

    fprintf('Answered %d on trial %d: payoff %d, probability %.2f, ambiguity %.2f\n', ...
      Data.choice(trial), trial, Data.vals(trial), Data.probs(trial), Data.ambigs(trial));
elseif keyisdown && keycode(KbName('2@'))        %% Reversed keys '2' and '1' - DE
    Data.choice(trial) = 2;
    Data.rt(trial) = elapsedTime;

    yellowDims = rightPos;
    whiteDims  = leftPos;

    yellowColor = [255 255 0];

    fprintf('Answered %d on trial %d: payoff %d, probability %.2f, ambiguity %.2f\n', ...
      Data.choice(trial), trial, Data.vals(trial), Data.probs(trial), Data.ambigs(trial))
else % non-press
    Data.choice(trial) = 0;
    Data.rt(trial) = NaN;

    yellowDims = leftPos;
    whiteDims  = rightPos;

    yellowColor = [255 255 255]; % NOTE: Actually white!

    fprintf('Failed to answer on trial %d: payoff %d, probability %.2f, ambiguity %.2f\n', ...
      trial, Data.vals(trial), Data.probs(trial), Data.ambigs(trial))
end

%% Display feedback (two squares)
Screen(Data.stimulus.win,'FillRect',yellowColor,yellowDims);
Screen(Data.stimulus.win,'FillRect',[255 255 255],whiteDims);
drawRef(Data)
Screen('flip',Data.stimulus.win);

Data.trialTime(trial).feedbackStartTime = datevec(now);
elapsedTime = etime(datevec(now),Data.trialTime(trial).feedbackStartTime);
while elapsedTime<Data.stimulus.feedbackDur
    elapsedTime = etime(datevec(now),Data.trialTime(trial).feedbackStartTime);
end

%% Display ITI (white circle)
Screen('FillOval', Data.stimulus.win, [255 255 255], [Data.stimulus.winrect(3)/2-20 Data.stimulus.winrect(4)/2-20 Data.stimulus.winrect(3)/2+20 Data.stimulus.winrect(4)/2+20]);
drawRef(Data)
Screen('flip',Data.stimulus.win);

Data.trialTime(trial).ITIStartTime = datevec(now);
elapsedTime = etime(datevec(now),Data.trialTime(trial).trialStartTime);
while elapsedTime<Data.stimulus.lottoDisplayDur+Data.stimulus.responseWindowDur+Data.stimulus.feedbackDur+Data.ITIs(trial)
    elapsedTime = etime(datevec(now),Data.trialTime(trial).trialStartTime);
end
end
