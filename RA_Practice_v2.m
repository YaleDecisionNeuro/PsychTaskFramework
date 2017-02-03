function RA_Practice_v2(observer)
%% Setup
settings = config();

% Set keys to Windows keys (script still works on OSX)
KbName(settings.device.KbName);

% Set random generator
s = RandStream.create('mt19937ar', 'seed', sum(100*clock));
RandStream.setGlobalStream(s);

% Remember current directory (used in non-practice scripts)
% TODO: Align with current script location `mfilename('fullpath')`
thisdir = pwd;
Data.filename = fullfile('data', num2str(observer), ['RA_GAINS_' num2str(observer)]);
% FIXME: What to save the data in?

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

%% Properties of lottery choices
Data.vals = settings.game.stakes;
Data.probs = settings.game.probs;
Data.ambigs = settings.game.ambigs;
Data.numTrials = settings.game.numTrials;
Data.ITIs  = settings.game.ITIs;
Data.colors = settings.game.colors;

%% Window settings
whichScreen = settings.device.screenId;
% Data.stimulus = settings.stimulus; % FIXME: Remove reliance on this

% Open a window
% TODO: Conditional on provided `settings.device.screenDims`?
[settings.device.windowPtr, settings.device.screenDims] = Screen('OpenWindow', ...
  whichScreen, settings.background.color);
windowPtr = settings.device.windowPtr;
HideCursor(windowPtr);
Screen('TextFont', windowPtr, settings.default.fontName);

% Paint background
Screen('FillRect', windowPtr, settings.background.color);

%% Block begins!
blockNum = 1;
Screen('TextSize', windowPtr, settings.default.fontSize);
DrawFormattedText(windowPtr, ['Block ' num2str(blockNum)], ...
  'center', 'center', settings.default.fontColor);
Screen('flip', windowPtr); % Display screen?
waitForBackTick; % Wait for 5 or @ to hit before proceeding

% NOTE: This is an abstraction for trials within a single block
for trial = 1 : settings.game.numTrials
    Data.trialTime(trial).trialStartTime = datevec(now);
    Data = drawTrial(Data, trial, settings); % Draw lottery
    Data.trialTime(trial).trialEndTime = datevec(now);

    blockNum = blockNum + 1;

    % Restore screen state + settings to default
    Screen('FillRect', windowPtr, settings.background.color);
    Screen('TextSize', windowPtr, settings.default.fontSize);
end

DrawFormattedText(windowPtr, 'Finished Practice', ...
  'center', 'center', settings.default.fontColor);

% Display screen and with for press of 5 to terminate
Screen('flip', windowPtr);
waitForBackTick;
Screen('CloseAll') % Turn screen off
end

% This function does much more than draw the lotto -- it displays the trial, obtains feedback, records it, and displays everything else before the beginning of the next trial
% TODO: Rename to `runTrial`
function Data = drawTrial(Data, trial, settings)
% Record the properties of this trial to Data
Data.vals(trial) = settings.game.stakes(trial);
Data.probs(trial) = settings.game.probs(trial);
Data.ambigs(trial) = settings.game.ambigs(trial);

% There are hard-coded `.Digit1`, `.Digit2` and `.Digit3` values in `setParams_LSRA`.
% They denote the dimensions in which the number should be placed in order to stay in the middle (?)

%% START: task
% Determine probabilities to associate with colors
[probOrder, amtOrder] = orderLotto(settings, trial);

% FIXME: Semantic naming
redProb = probOrder(1);
blueProb = probOrder(2);

% FIXME: This, technically, is only the bottom-right coordinate. If `rect`
% passed to Screen('OpenWindow', rect) began with two non-zero values, that's
% how far from the top-left of the screen PTB would start drawing.
% TODO: Abstract into a function -- given window pointer, get Width + Height.
W = settings.device.screenDims(3); % width
H = settings.device.screenDims(4); % height

boxHeight = settings.lottery.figure.dims(2);
Y1 = (H - boxHeight) / 2; % Space over the lottery box (top coordinate of display)
Y2 = Y1 + boxHeight * redProb; % Y coordinate of top probability's bottom
Y3 = Y2 + boxHeight * blueProb; % Y coordinate of bottom probability's bottom

% Occluder coordinates
ambig = settings.game.ambigs(trial);
nonAmbigPart = 1 - ambig; % how much of the prob box is definite?
Y2occ = Y1 + boxHeight * (nonAmbigPart / 2); % top of occluder
Y3occ = Y2occ + boxHeight * ambig; % bottom of occluder

% Colors
% NOTE: Order of colors remains constant
colors = settings.lottery.figure.colors.prob;
color_ambig = settings.lottery.figure.colors.ambig;
color_bgr = settings.background.color;

% NOTE: The lottery is always displayed in the horizontal center of the screen
screenCenter = W / 2;
halfBox = settings.lottery.figure.dims(1) / 2;

windowPtr = settings.device.windowPtr;

% Paint the whole screen (default without coordinates)
Screen('FillRect', windowPtr, color_bgr);

drawRef(settings, Data.refSide)

lottoDims = [screenCenter - halfBox, Y1, screenCenter + halfBox, Y2];
Screen('FillRect', windowPtr, colors(1, :), lottoDims);

lottoDims = [screenCenter - halfBox, Y2, screenCenter + halfBox, Y3];
Screen('FillRect', windowPtr, colors(2, :), lottoDims);

clear lottoDims;

% Occluder is painted over
lottoAmbigDims = [screenCenter - halfBox, Y2occ, screenCenter + halfBox, Y3occ];
Screen('FillRect', windowPtr, color_ambig, lottoAmbigDims);

%% Draw the amounts! Red is always on top
% Retrieve the dimensions (due to different length) of the amount labels
digitWidth = ones(1, 2);
digitHeight = ones(1, 2);
for i = 1:length(amtOrder)
  digit_field = sprintf('Digit%g', length(num2str(amtOrder(i))));
  temp = settings.lottery.stakes.misc.(digit_field);
  digitWidth(i) = temp(1);
  digitHeight(i) = temp(2);
end
clear temp;

randomConstantAdjustment = 50; % FIXME: Random constant adjustment
xCoords = [W/2 - digitWidth(1)/2, W/2 - digitWidth(2)/2];
yCoords = [Y3, Y1 - digitHeight(1)] + randomConstantAdjustment;

Screen(windowPtr, 'TextSize', settings.lottery.stakes.fontSize);
DrawFormattedText(windowPtr, sprintf('$%s', num2str(amtOrder(1))), ...
  xCoords(1), yCoords(1), settings.lottery.stakes.fontColor);
DrawFormattedText(windowPtr, sprintf('$%s', num2str(amtOrder(2))), ...
  xCoords(2), yCoords(2), settings.lottery.stakes.fontColor);

%% Draw probability numbers
% Compute coordinates
% This time, we assume all probabilities are double-digit
textDim = settings.lottery.probLabels.dims;

xCoord = W/2 - textDim(1)/2;
yCoord = [Y1 + 0.5 * (Y2 - Y1) - textDim(2)/2, ...
  Y2 + 0.5 * (Y3 - Y2) - textDim(2)/2];

% Logic of `/4`: only half the ambiguity diminishes either side of the
% probability, and it cuts the position of text in another half
ambigYAdjustment = boxHeight * ambig / 4;
yCoord = yCoord + [-ambigYAdjustment, ambigYAdjustment] + randomConstantAdjustment / 2;

probNumbers = probOrder - ambig / 2; % Keeps the numbers same if no ambiguity

Screen(windowPtr, 'TextSize', settings.lottery.probLabels.fontSize);
DrawFormattedText(windowPtr, sprintf('%s', num2str(probNumbers(1)*100)), ...
  xCoord, yCoord(1), settings.lottery.probLabels.fontColor);
DrawFormattedText(windowPtr, sprintf('%s', num2str(probNumbers(2)*100)), ...
  xCoord, yCoord(2), settings.lottery.probLabels.fontColor);

Screen('flip', windowPtr);

elapsedTime = etime(datevec(now), Data.trialTime(trial).trialStartTime);
while elapsedTime < settings.game.choiceDisplayDur
    elapsedTime = etime(datevec(now), Data.trialTime(trial).trialStartTime);
end

%% START: prompt_and_feedback
% Display green dot, signifying the beginning of response time
center = [W / 2, H / 2];
Screen('FillOval', windowPtr, settings.prompt.color, ...
  centerRectDims(center, settings.prompt.dims));

% Note how long the prompt appeared
Screen('flip', windowPtr);
Data.trialTime(trial).respStartTime = datevec(now);

% Condition its disappearance
% TODO: If s.game.responseWindowDur == 0, there shouldn't be a while condition
% TODO: Abstract into `waitForBackTick`-like function
% TODO: `elapsedTime` - better name?
elapsedTime = etime(datevec(now), Data.trialTime(trial).respStartTime);
while elapsedTime < settings.game.responseWindowDur
  % Add sleep(0.05) to not fry the computer?
  [keyisdown, secs, keycode, deltaSecs] = KbCheck;
  if keyisdown && (keycode(KbName('2@')) || keycode(KbName('1!')))
    elapsedTime = etime(datevec(now), Data.trialTime(trial).respStartTime);
    break
  end
  elapsedTime = etime(datevec(now), Data.trialTime(trial).respStartTime);
end

% Note RT (might be overridden if this was a non-response)
Data.rt(trial) = elapsedTime;

%% START: feedback
%% Base for computation of feedback box positions
% left-top-right-bottom border in px

% TODO: Extract
% TODO: 20 and 40 are magical numbers denoting (half) square width -- settings
feedbackSize = settings.feedback.dims;
pxOffCenter = [0.05 * W, 0];
center = [W / 2, H / 2];

% NOTE: Use structs?
button1 = centerRectDims(center, feedbackSize, -pxOffCenter);
button2 = centerRectDims(center, feedbackSize, pxOffCenter);

button1_color = settings.feedback.colorNoAnswer;
button2_color = settings.feedback.colorNoAnswer;

%% Record choice & assign feedback color
% TODO: If a function can translate choice + refSide into a lottery choice,
% this could flag stochastic dominance violations as they happen
if keyisdown && keycode(KbName('1!'))
    Data.choice(trial) = 1;
    button1_color = settings.feedback.colorAnswer;
elseif keyisdown && keycode(KbName('2@'))
    Data.choice(trial) = 2;
    button2_color = settings.feedback.colorAnswer;
else % non-press
    Data.choice(trial) = 0;
    Data.rt(trial) = NaN;
end

%% Display feedback (two squares)
Screen('FillRect', windowPtr, button1_color, button1);
Screen('FillRect', windowPtr, button2_color, button2);
disp(choiceReport(Data, trial));

% Re-draw reference and note feedback length
Screen('flip', windowPtr); % NOTE: This makes no sense. Why are we using it if we're not taking our time measurements from it?

Data.trialTime(trial).feedbackStartTime = datevec(now);
elapsedTime = etime(datevec(now), Data.trialTime(trial).feedbackStartTime);
while elapsedTime < settings.game.feedbackDur
    elapsedTime = etime(datevec(now), Data.trialTime(trial).feedbackStartTime);
end

%% START: intertrial
%% Display ITI sign (white circle)
Screen('FillOval', windowPtr, settings.intertrial.color, ...
  centerRectDims(center, settings.intertrial.dims));
Screen('flip', windowPtr);

Data.trialTime(trial).ITIStartTime = datevec(now);

elapsedTime = etime(datevec(now), Data.trialTime(trial).trialStartTime);

totalTrialTime = settings.game.choiceDisplayDur + ...
  settings.game.responseWindowDur + ...
  settings.game.feedbackDur + ...
  settings.game.ITIs(trial);
while elapsedTime < totalTrialTime
    elapsedTime = etime(datevec(now), Data.trialTime(trial).trialStartTime);
end
end
