function RA(observer)
% Written side-by-side with RA_GAINS1

%% Setup
settings = config();
KbName(settings.device.KbName);

% Set random generator
s = RandStream.create('mt19937ar', 'seed', sum(100*clock));
RandStream.setGlobalStream(s);

% Find-or-create participant data file
fname = [num2str(observer) '.mat'];
folder = fullfile(pwd, 'data');
fname = [folder filesep fname];
Data = loadOrCreate(fname); % TODO: Create

% Save participant ID + date
% TODO: Prompt for correctness before launching PTB?
Data.observer = observer;
Data.date = datestr(now, 'yyyymmddTHHMMSS'); % FIXME: This should be conditional
if mod(observer, 2) == 0
    Data.refSide = 1; % left
else
    Data.refSide = 2; % right
end

%% Generate trials/blocks - or check whether it's been generated before?
% Generate order of trials in a single table, then iterate n at a time?
% Generate a number of separate blocks, then iterate through them?
% Just run trials with ad-hoc intermissions? (This was the old way, sort of)

%% Set up window
% TODO: Conditional on provided `settings.device.screenDims`?
[settings.device.windowPtr, settings.device.screenDims] = ...
  Screen('OpenWindow', settings.device.screenId, ...
  settings.background.color);
windowPtr = settings.device.windowPtr;

%% Display blocks
% Option A: Iterate over blocks, passing to runBlock all it'll need in a loop
% Option B: Run each block with separate settings; handle any prompts / continuations here, or pass different callbacks
% Option C: Run things trial-by-trial, passing different settings to each
% Option D: Run down a table of trials, each with a "block type", and let runTrial handle each
end
