function RA_Practice_v2(observer)
%% Setup
settings = config(); % Default values; change by assignment
KbName(settings.device.KbName);

% Set random generator
s = RandStream.create('mt19937ar', 'seed', sum(100*clock));
RandStream.setGlobalStream(s);

% Remember current directory (used in non-practice scripts)
% TODO: Align with current script location `mfilename('fullpath')`
thisdir = pwd;
Data.filename = fullfile('data', num2str(observer), ['RA_' num2str(observer)]);
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
% Open a window
% TODO: Conditional on provided `settings.device.screenDims`?
[settings.device.windowPtr, settings.device.screenDims] = Screen('OpenWindow', ...
  whichScreen, settings.background.color);
windowPtr = settings.device.windowPtr;

% Paint background
drawBgr(Data, settings);

%% Block begins!
blockNum = 1;
DrawFormattedText(windowPtr, ['Block ' num2str(blockNum)], ...
  'center', 'center', settings.default.fontColor);
Screen('flip', windowPtr); % Display screen?
waitForBackTick; % Wait for 5 or @ to hit before proceeding

% NOTE: This is an abstraction for trials within a single block
for trial = 1 : settings.game.numTrials
  Data.trialTime(trial).trialStartTime = datevec(now);
  Data = drawTrial(Data, trial, settings); % Draw lottery
  Data.trialTime(trial).trialEndTime = datevec(now);

  % blockNum = blockNum + 1;
  drawBgr(Data, settings);
end

DrawFormattedText(windowPtr, 'Finished Practice', ...
  'center', 'center', settings.default.fontColor);

% Display screen and with for press of 5 to terminate
Screen('flip', windowPtr);
waitForBackTick;
Screen('CloseAll') % Turn screen off
end

% This function displays the trial choice, obtains feedback, records it, and
% displays everything else before the beginning of the next trial
function Data = drawTrial(Data, trial, settings)
% Record the properties of this trial to Data
Data.currTrial = trial; % FIXME: this is dumb, there must be a better way

Data = drawTask(Data, settings);
Data = handleResponse(Data, settings);
disp(choiceReport(Data, trial));
Data = drawFeedback(Data, settings);
Data = drawIntertrial(Data, settings);
end
