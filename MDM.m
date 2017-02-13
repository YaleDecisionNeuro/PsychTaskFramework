function MDM(observer)
% MDM Runs a medical decision-making task and records its results for the
%   participant whose subject number is passed in. Modeled on (and largely
%   copy-pasted from) RA.m, to test out image implementation (#5).

%% Add subfolders we'll be using to path
addpath(genpath('./lib'));
addpath(genpath('./tasks/MDM'));
% NOTE: genpath gets the directory and all its subdirectories

%% Load settings
settings = MDM_config();

%% Setup
KbName(settings.device.KbName);
s = RandStream.create('mt19937ar', 'seed', sum(100*clock));
RandStream.setGlobalStream(s);

if exist('observer', 'var') % Running actual trials -> record
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
    Data.date = datestr(now, 'yyyymmddTHHMMSS');
  end

  % Save participant ID + date
  % TODO: Prompt for correctness before launching PTB?
  Data.observer = observer;
  Data.lastAccess = datestr(now, 'yyyymmddTHHMMSS');
  if mod(observer, 2) == 0
      settings.perUser.refSide = 1;
  else
      settings.perUser.refSide = 2;
  end
else % Running practice
  Data.observer = 1;
  settings.perUser.refSide = randi(2);
  settings.device.saveAfterBlock = false;
end

%% Generate trials
% TODO: Also generate monetary block
trials = generateTrialOrder(settings.game.levels);
numTrials = height(trials);

trials.stakes_loss = repmat(settings.game.levels.stakes_loss, numTrials, 1);
trials.reference = repmat(settings.game.levels.reference, numTrials, 1);

perBlockITIs = settings.game.durations.ITIs;
trials.ITIs = repmat(perBlockITIs, numTrials / length(perBlockITIs), 1);

% Open window
[settings.device.windowPtr, settings.device.screenDims] = ...
  Screen('OpenWindow', settings.device.screenId, ...
  settings.default.bgrColor);

%% Finalize settings
settings.game.trials = trials(1:3, :);
settings.textures = loadTexturesFromConfig(settings);
% NOTE: Can only load textures with an open window, this is why we're loading
%   this late

% Run
if ~exist('observer', 'var') % Run practice
  settings.game.trials = trials(randperm(numTrials, 3), :);
  Data = runBlock(Data, settings);
else
  settings.game.trials = trials(1:3, :);
  Data = runBlock(Data, settings);
end

% Close window
Screen('CloseAll');
end
