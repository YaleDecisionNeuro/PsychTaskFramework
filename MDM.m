function [ Data ] = MDM(observer)
% MDM Runs a medical decision-making task and records its results for the
%   participant whose subject number is passed in. Modeled on (and largely
%   copy-pasted from) RA.m, to test out image implementation (#5).

%% Add subfolders we'll be using to path
addpath(genpath('./lib'));
addpath(genpath('./tasks/MDM'));
% NOTE: genpath gets the directory and all its subdirectories

%% Setup
settings = MDM_config();
settings = loadPTB(settings);

if exist('observer', 'var') % Running actual trials -> record
  % Find-or-create participant data file *in appropriate location*
  fname = [num2str(observer) '.mat'];
  folder = fullfile(settings.task.taskPath, 'data');
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
      settings.runSetup.refSide = 1;
  else
      settings.runSetup.refSide = 2;
  end
else % Running practice
  Data.observer = NaN;
  settings.runSetup.refSide = randi(2);
  settings.device.saveAfterBlock = false;
  settings.device.saveAfterTrial = false;
end

% Disambiguate settings here
monSettings = MDM_config_monetary(settings);
medSettings = MDM_config_med(settings);
medSettings.runSetup.textures = loadTexturesFromConfig(medSettings);
monSettings.runSetup.textures = loadTexturesFromConfig(monSettings);

%% Generate trials if not generated already
if ~isfield(Data, 'blocks') || ~isfield(Data.blocks, 'planned')
  % MDM uses a particular set of trials, so we have to generate some trials
  % manually. Luckily, these can be shared across both kinds of blocks two
  % tasks, as their value range is equal. If that were not the case, they would
  % need to be disambiguated.

  % 1. Generate 1 repeat of reference level trials, all possible P/A values
  tempLevels = medSettings.trial.generate;
  tempLevels.stakes = tempLevels.reference;
  tempLevels.repeats = 1;
  fillTrials = generateTrials(tempLevels);
  % fillTrials = fillTrials(randperm(height(fillTrials), 4), :)

  % 2. Generate 2 additional trials with reference payoff
  tempLevels = medSettings.trial.generate;
  tempLevels.stakes = tempLevels.reference;
  tempLevels.probs = 0.25;
  tempLevels.ambigs = 0.5;
  tempLevels.repeats = 1;
  fillTrials = [fillTrials; generateTrials(tempLevels)];
  % fillTrials = fillTrials(randperm(height(fillTrials), 2), :)

  % 3. Have generateBlocks create the standard number of repeats with
  %    non-reference values
  tempMedSettings = medSettings;
  tempMedSettings.trial.generate.stakes = medSettings.trial.generate.stakes(2:end);
  medBlocks = generateBlocks(tempMedSettings, medSettings.trial.generate.catchTrial, ...
    medSettings.trial.generate.catchIdx, fillTrials);

  tempMonSettings = monSettings;
  tempMonSettings.trial.generate.stakes = monSettings.trial.generate.stakes(2:end);
  monBlocks = generateBlocks(tempMonSettings, monSettings.trial.generate.catchTrial, ...
    monSettings.trial.generate.catchIdx, fillTrials);

  % 4. Determine and save the order of blocks
  lastDigit = mod(Data.observer, 10);
  medFirst = ismember(lastDigit, [1, 2, 5, 6, 9]);
  medIdx = [1 1 0 0];
  if ~medFirst
    medIdx = 1 - medIdx; % flip
  end

  numBlocks = length(medIdx);
  Data.blocks.planned = cell(numBlocks, 1);
  Data.blocks.recorded = cell(0);
  Data.blocks.numRecorded = 0;
  for blockIdx = 1:numBlocks
    blockKind = medIdx(blockIdx);
    withinKindIdx = sum(medIdx(1 : blockIdx) == blockKind);
    if blockKind == 1
      Data.blocks.planned{blockIdx} = struct('trials', ...
        medBlocks{withinKindIdx}, 'blockKind', blockKind);
    else
      Data.blocks.planned{blockIdx} = struct('trials', ...
        monBlocks{withinKindIdx}, 'blockKind', blockKind);
    end
  end
end

% Display blocks
firstBlockIdx = Data.blocks.numRecorded + 1;
lastBlockIdx = 4; % FIXME: Derive from settings

if exist('observer', 'var')
  for blockIdx = firstBlockIdx:lastBlockIdx
    if Data.blocks.planned{blockIdx}.blockKind == 0
      blockSettings = monSettings;
    else
      blockSettings = medSettings;
    end
    blockSettings.game.trials = Data.blocks.planned{blockIdx}.trials;
    Data = runBlock(Data, blockSettings);
  end
else
  % Run practice -- only first n trials of first two blocks?
  numSelect = 3;
  for blockIdx = 2:3 % Known to be two different blocks
    if Data.blocks.planned{blockIdx}.blockKind == 0
      blockSettings = monSettings;
    else
      blockSettings = medSettings;
    end
    randomIdx = randperm(blockSettings.task.blockLength, numSelect);
    blockSettings.game.trials = Data.blocks.planned{blockIdx}.trials(randomIdx, :);
    Data = runBlock(Data, blockSettings);
  end
end

% Close window
Screen('CloseAll');
end
