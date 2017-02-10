function RA(observer)
% RA Main task script for the monetary risk and ambiguity task. Loads settings,
%   executes requisite blocks, and records data for the subject whose ID is
%   passed as an argument.
%
% It bears noting that in its general outline, this script can be written to
% conduct any form of the trial -- all of RA_Practice, RA_Gains, and RA_Loss
% can be established here. (If you add logic for condition assignment and
% detection of past recorded trials, you'll be able to invoke this script with
% the same call for both sessions -- it will just keep adding the new data to
% `.recordedBlocks`).

%% Setup
settings = config();
KbName(settings.device.KbName);

% Set random generator
s = RandStream.create('mt19937ar', 'seed', sum(100*clock));
RandStream.setGlobalStream(s);

% TODO: If `observer` isn't passed, (1) don't load/save the file and (2) only
% run one block each of gains and losses

% Find-or-create participant data file *in appropriate location*
fname = [num2str(observer) '.mat'];
folder = fullfile(pwd, 'data');
fname = [folder filesep fname];
[ Data, participantExisted ] = loadOrCreate(observer, fname);

% TODO: Prompt experimenter if this is correct
if participantExisted
  disp('Participant file exists, reusing...')
else
  disp('Participant has no file, creating...')
end

% Save participant ID + date
% TODO: Prompt for correctness before launching PTB?
Data.observer = observer;
Data.date = datestr(now, 'yyyymmddTHHMMSS'); % FIXME: This should be conditional
if mod(observer, 2) == 0
    Data.refSide = 1; % left
    settings.perUser.refSide = 1;
else
    Data.refSide = 2; % right
    settings.perUser.refSide = 2;
end

%% Generate trials/blocks - or check whether it's been generated before?
% Generate order of trials in a single table, then iterate n at a time?
% Generate a number of separate blocks, then iterate through them?
% Just run trials with ad-hoc intermissions? (This was the old way, sort of)

% 1. Bring in levels from `settings`
% 2. Define the repeat row
% 3. Bring in RA_generateTrialOrder to create `trials`
% 4. Add the constant columns (stakes_loss, reference_value, trial_type)
% 5. Mix around ITI order
% 6. Pass row subsets to runBlock
%
% TODO: Mix in with losses right here? How?

repeatRow = table(4, 0.5, 0, randperm(2, 1), 'VariableNames', {'stakes', 'probs', 'ambigs', 'colors'});
repeatIndex = [1 32 63 94]; % TODO: Derive from block.length and repeatPosition
% TODO: Extract the row injection into a separate function done after the fact,
% so that it can be done without knowledge of the result
trials = RA_generateTrialOrder(settings.game.levels, ...
  repeatRow, repeatIndex);
numTrials = height(trials);
trials.stakes_loss = repmat(settings.game.levels.stakes_loss, numTrials, 1);
trials.reference = repmat(settings.game.levels.reference, numTrials, 1);

perBlockITIs = settings.game.durations.ITIs;
trials.ITIs = repmat(shuffle(perBlockITIs)', numTrials / length(perBlockITIs), 1);
% TODO: Extract helper function to add a constant value in a table column

%% Set up window
% TODO: Conditional on provided `settings.device.screenDims`?
[settings.device.windowPtr, settings.device.screenDims] = ...
  Screen('OpenWindow', settings.device.screenId, ...
  settings.default.bgrColor);

%% Display blocks
% Strategy: Run each block with separate settings; define its trials by
% subsetting them; handle any prompts / continuations here, or pass different
% callbacks

% TODO: Create a local function that will take default config and change it
% into a loss/gains config prior to that block.
settings.game.trials = trials(1:3, :);
settings.game.block.kind = 'Gains'; % For simple reconstruction later
settings.game.trialFn = @RA_drawTrial; % For specific handling of task

Data = runBlock(Data, settings);
% TODO: Other blocks

Screen('CloseAll');
end

function arr = shuffle(arr)
% SHUFFLE Helper function that randomly shuffles a one-deimsional object
%   (by design, a matrix).
  newOrder = randperm(length(arr));
  arr = arr(newOrder);
end
