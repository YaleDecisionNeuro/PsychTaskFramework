function RA_Practice_v2(observer)
%% Setup
% Set keys to Windows keys (script still works on OSX)
% TODO: Condition on system detection? Or, abstract settings into a file explicitly labeled as such, and referenced in globals?
KbName('KeyNamesWindows');

% Set random generator
s = RandStream.create('mt19937ar', 'seed', sum(100*clock));
RandStream.setGlobalStream(s);

% Remember current directory (used in non-practice scripts)
% TODO: Align with current script location `mfilename('fullpath')`
thisdir = pwd;
Data.filename = fullfile('data', num2str(observer), ['RA_GAINS_' num2str(observer)]);

% Save participant ID + date
% TODO: Prompt for correctness before launching PTB?
Data.observer = observer;
Data.date = datestr(now, 'yyyymmddTHHMMSS');

% Randomize the side of sure choice by participant ID
% TODO: Add more descriptive variable than refSide? (Need to remain backwards-compatible.)
% Alternative TODO: Keep this, but also record underlying choice, not the side it's on
if mod(observer, 2) == 0
    Data.refSide = 1; % left
else
    Data.refSide = 2; % right
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
% Data.vals = [13 72]';
% Data.probs = [.25 .5]';
% Data.ambigs = [0 .24]';
% Data.numTrials = length(Data.vals);
% Data.ITIs  = [8 4];
% Data.colors = [2 1]; % TODO: Is this the best way to set colors?
Data.vals = [5 16 19 111 72 9]';
Data.probs = [.5 .5 .25 .5 .25 .5]';
Data.ambigs = [0 .24 0 .74 0 .24]';
Data.numTrials = length(Data.vals);
Data.ITIs  = [1 1 1 1 1 1];
Data.colors = [2 1 2 1 2 2];

Screen(Data.stimulus.win, 'FillRect', 1); % Clear window?

%% Experiment begins!
blockNum = 1;

Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize. lotteryValues);
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

function Data=drawLotto_LSRA(Data, trial)

% There are hard-coded `.Digit1`, `.Digit2` and `.Digit3` values in `setParams_LSRA`.
% They denote the dimensions in which the number should be placed in order to stay in the middle (?)

% Determine probabilities to associate with colors
[probOrder, amtOrder] = orderLotto(Data, trial);


% FIXME: Semantic naming
redProb = probOrder(1);
blueProb = probOrder(2);

H = Data.stimulus.winrect(4); % height
W = Data.stimulus.winrect(3); % width
boxHeight = Data.stimulus.lotto.height;
Y1 = (H - boxHeight) / 2; % Space over the lottery box (top coordinate of display)
Y2 = Y1 + boxHeight * redProb; % Y coordinate of top probability's bottom
Y3 = Y2 + boxHeight * blueProb; % Y coordinate of bottom probability's bottom

% Occluder coordinates
ambig = Data.ambigs(trial);
nonAmbigPart = 1 - ambig; % how much of the prob box is definite?
Y2occ = Y1 + boxHeight * (nonAmbigPart / 2); % top of occluder
Y3occ = Y2occ + boxHeight * ambig; % bottom of occluder

% Colors
colors = Data.stimulus.colors_prob;
color_ambig = Data.stimulus.color_ambig;
color_bgr = Data.stimulus.color_background;

% NOTE: The lottery is always displayed in the horizontal center of the screen
screenCenter = W / 2;
halfBox = Data.stimulus.lotto.width / 2;

% Paint the whole screen (default without coordinates)
% Order of colors remains constant
Screen(Data.stimulus.win, 'FillRect', color_bgr);

lottoDims = [screenCenter - halfBox, Y1, screenCenter + halfBox, Y2];
Screen(Data.stimulus.win, 'FillRect', colors(1, :), lottoDims);

lottoDims = [screenCenter - halfBox, Y2, screenCenter + halfBox, Y3];
Screen(Data.stimulus.win, 'FillRect', colors(2, :), lottoDims);

clear lottoDims;

% Occluder is painted over
lottoAmbigDims = [screenCenter - halfBox, Y2occ, screenCenter + halfBox, Y3occ];
Screen(Data.stimulus.win, 'FillRect', color_ambig, lottoAmbigDims);

%% Draw the amounts! Red is always on top
% Retrieve the dimensions (due to different length) of the amount labels
digitWidth = ones(1, 2);
digitHeight = ones(1, 2);
for i = 1:length(amtOrder)
  digit_field = sprintf('Digit%g', length(num2str(amtOrder(i))));
  temp = Data.stimulus.textDims.lotteryValues.(digit_field);
  digitWidth(i) = temp(1);
  digitHeight(i) = temp(2);
end
clear temp;

xCoords = [W/2 - digitWidth(1)/2, W/2 - digitWidth(2)/2];
yCoords = [Y3, Y1 - digitHeight(1)];

Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.lotteryValues);
DrawFormattedText(Data.stimulus.win, sprintf('$%s', num2str(amtOrder(1))), ...
  xCoords(1), yCoords(1), Data.stimulus.fontColor);
DrawFormattedText(Data.stimulus.win, sprintf('$%s', num2str(amtOrder(2))), ...
  xCoords(2), yCoords(2), Data.stimulus.fontColor);

%% Draw probability numbers
% Compute coordinates
% This time, we assume all probabilities are double-digit
textDim = Data.stimulus.textDims.probabilities;

xCoord = W/2 - textDim(1)/2;
yCoord = [Y1 + 0.5 * (Y2 - Y1) - textDim(2)/2, ...
  Y2 + 0.5 * (Y3 - Y2) - textDim(2)/2];

% Logic of `/4`: only half the ambiguity diminishes either side of the
% probability, and it cuts the position of text in another half
ambigYAdjustment = boxHeight * ambig / 4;
yCoord = yCoord + [-ambigYAdjustment, ambigYAdjustment];

probNumbers = probOrder - ambig / 2; % Keeps the numbers same if no ambiguity

Screen('TextSize', Data.stimulus.win, Data.stimulus.fontSize.probabilities);
DrawFormattedText(Data.stimulus.win, sprintf('%s', num2str(probNumbers(1)*100)), ...
  xCoord, yCoord(1), Data.stimulus.fontColor);
DrawFormattedText(Data.stimulus.win, sprintf('%s', num2str(probNumbers(2)*100)), ...
  xCoord, yCoord(2), Data.stimulus.fontColor);

drawRef(Data)
Screen('flip', Data.stimulus.win);

elapsedTime = etime(datevec(now), Data.trialTime(trial).trialStartTime);
while elapsedTime < Data.stimulus.lottoDisplayDur
    elapsedTime = etime(datevec(now), Data.trialTime(trial).trialStartTime);
end

%% Display green dot, signifying the beginning of response time
Screen('FillOval', Data.stimulus.win, [0 255 0], [W/2-20 H/2-20 W/2+20 H/2+20]);
drawRef(Data)
Screen('flip', Data.stimulus.win);
Data.trialTime(trial).respStartTime = datevec(now);
elapsedTime = etime(datevec(now), Data.trialTime(trial).respStartTime);
while elapsedTime < Data.stimulus.responseWindowDur
    [keyisdown, secs, keycode, deltaSecs] = KbCheck;
    if keyisdown && (keycode(KbName('2@')) || keycode(KbName('1!')))
        elapsedTime = etime(datevec(now), Data.trialTime(trial).respStartTime);
        break
    end
    elapsedTime = etime(datevec(now), Data.trialTime(trial).respStartTime);
end

% Note RT (might be overridden if this was a non-response)
Data.rt(trial) = elapsedTime;

%% Base for computation of feedback box positions
% left-top-right-bottom border in px

% TODO: Extract
% TODO: 20 and 40 are magical numbers denoting (half) square width -- settings
feedbackSize = [40 40];
pxOffCenter = [0.05 * W, 0];
center = [W / 2, H / 2];

% TODO: Use structs?
button1 = centerRectDims(center, feedbackSize, -pxOffCenter);
button2 = centerRectDims(center, feedbackSize, pxOffCenter);
button1_color = [255 255 255];
button2_color = [255 255 255];

%% Record choice & assign feedback color
% TODO: If a function can translate choice + refSide into a lottery choice,
% this could flag stochastic dominance violations as they happen
if keyisdown && keycode(KbName('1!'))
    Data.choice(trial) = 1;
    button1_color = [255 255 0];
elseif keyisdown && keycode(KbName('2@'))
    Data.choice(trial) = 2;
    button2_color = [255 255 0];
else % non-press
    Data.choice(trial) = 0;
    Data.rt(trial) = NaN;
end

%% Display feedback (two squares)
Screen(Data.stimulus.win, 'FillRect', button1_color, button1);
Screen(Data.stimulus.win, 'FillRect', button2_color, button2);
disp(choiceReport(Data, trial));

% Re-draw reference and note feedback length
drawRef(Data)
Screen('flip', Data.stimulus.win);

Data.trialTime(trial).feedbackStartTime = datevec(now);
elapsedTime = etime(datevec(now), Data.trialTime(trial).feedbackStartTime);
while elapsedTime < Data.stimulus.feedbackDur
    elapsedTime = etime(datevec(now), Data.trialTime(trial).feedbackStartTime);
end

%% Display ITI (white circle)
Screen('FillOval', Data.stimulus.win, [255 255 255], centerRectDims(center, feedbackSize));
drawRef(Data)
Screen('flip', Data.stimulus.win);

Data.trialTime(trial).ITIStartTime = datevec(now);

elapsedTime = etime(datevec(now), Data.trialTime(trial).trialStartTime);

totalTrialTime = Data.stimulus.lottoDisplayDur + ...
  Data.stimulus.responseWindowDur + ...
  Data.stimulus.feedbackDur + ...
  Data.ITIs(trial);
while elapsedTime < totalTrialTime
    elapsedTime = etime(datevec(now), Data.trialTime(trial).trialStartTime);
end
end
