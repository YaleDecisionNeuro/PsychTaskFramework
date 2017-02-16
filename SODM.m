function SODM(observer)
% SODM Runs a self-other monetary and medical decision-making task and records
%   its results for the participant whose subject number is passed in. Modeled
%   on (and largely copy-pasted from) RA.m, to test out image implementation
%   (#5).

%% Add subfolders we'll be using to path
addpath(genpath('./lib'));
addpath(genpath('./tasks/SODM'));
% NOTE: genpath gets the directory and all its subdirectories

%% Load settings
settings = SODM_config();

%% Setup
KbName(settings.device.KbName);
s = RandStream.create('mt19937ar', 'seed', sum(100*clock));
RandStream.setGlobalStream(s);

if exist('observer', 'var') % Running actual trials -> record
  % Find-or-create participant data file *in appropriate location*
  fname = [num2str(observer) '.mat'];
  folder = fullfile(settings.device.taskPath, 'data');
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

% Open window
[settings.device.windowPtr, settings.device.screenDims] = ...
  Screen('OpenWindow', settings.device.screenId, ...
  settings.default.bgrColor);

%% Generate trials
% 1. Monetary blocks
medSettings = SODM_config_medical(settings)
medTrials = generateTrialOrder(medSettings.game.levels);
numMedTrials = height(medTrials);

medTrials.stakes_loss = repmat(medSettings.game.levels.stakes_loss, numMedTrials, 1);
medTrials.reference = repmat(medSettings.game.levels.reference, numMedTrials, 1);

perBlockITIs = medSettings.game.durations.ITIs;
medTrials.ITIs = repmat(perBlockITIs, numMedTrials / length(perBlockITIs), 1);

medSettings.textures = loadTexturesFromConfig(medSettings);

clear perBlockITIs;

% 2. Monetary blocks
moneySettings = SODM_config_monetary(settings);
moneyTrials = generateTrialOrder(moneySettings.game.levels);
numMoneyTrials = height(moneyTrials);

moneyTrials.stakes_loss = repmat(moneySettings.game.levels.stakes_loss, numMoneyTrials, 1);
moneyTrials.reference = repmat(moneySettings.game.levels.reference, numMoneyTrials, 1);

perBlockITIs = moneySettings.game.durations.ITIs;
moneyTrials.ITIs = repmat(perBlockITIs, numMoneyTrials / length(perBlockITIs), 1);

moneySettings.textures = loadTexturesFromConfig(moneySettings);

% NOTE: Just for testing, limiting block length
moneySettings.game.trials = moneyTrials(1:3, :);
medSettings.game.trials = medTrials(1:3, :);

% Run
if ~exist('observer', 'var') % Run practice
  medSettings.game.trials = medTrials(randperm(numMoneyTrials, 3), :);
  Data = runBlock(Data, medSettings);
  moneySettings.game.trials = moneyTrials(randperm(numMoneyTrials, 3), :);
  Data = runBlock(Data, moneySettings);
else
  medSettings.game.trials = medTrials(1, :);
  Data = runBlock(Data, medSettings);
  moneySettings.game.trials = moneyTrials(randperm(numMoneyTrials, 1), :);
  Data = runBlock(Data, moneySettings);
end

% Close window
Screen('CloseAll');
end
