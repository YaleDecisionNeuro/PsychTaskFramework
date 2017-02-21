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

% Set up window
[settings.device.windowPtr, settings.device.screenDims] = ...
  Screen('OpenWindow', settings.device.screenId, ...
  settings.default.bgrColor);

% Disambiguate settings here
monSettings = MDM_config_monetary(settings);
medSettings = MDM_config_med(settings);
medSettings.textures = loadTexturesFromConfig(medSettings);
monSettings.textures = loadTexturesFromConfig(monSettings);

%% Generate trials if not generated already
if ~isfield(Data, 'blocks') || ~isfield(Data.blocks, 'planned')
  % MDM uses a particular set of trials, so we have to generate some trials
  % manually. Luckily, these can be shared across both kinds of blocks two
  % tasks, as their value range is equal. If that were not the case, they would
  % need to be disambiguated.

  % 1. Generate 1 repeat of reference level trials, all possible P/A values
  tempLevels = medSettings.game.levels;
  tempLevels.stakes = tempLevels.reference;
  tempLevels.repeats = 1;
  fillTrials = generateTrials(tempLevels);
  % fillTrials = fillTrials(randperm(height(fillTrials), 4), :)

  % 2. Generate 2 additional trials with reference payoff
  tempLevels = medSettings.game.levels;
  tempLevels.stakes = tempLevels.reference;
  tempLevels.probs = 0.25;
  tempLevels.ambigs = 0.5;
  tempLevels.repeats = 1;
  fillTrials = [fillTrials; generateTrials(tempLevels)];
  % fillTrials = fillTrials(randperm(height(fillTrials), 2), :)

  % 3. Have generateBlocks create the standard number of repeats with
  %    non-reference values
  tempMedSettings = medSettings;
  tempMedSettings.game.levels.stakes = medSettings.game.levels.stakes(2:end);
  medBlocks = generateBlocks(tempMedSettings, medSettings.game.block.repeatRow, ...
    medSettings.game.block.repeatIndex, fillTrials);

  tempMonSettings = monSettings;
  tempMonSettings.game.levels.stakes = monSettings.game.levels.stakes(2:end);
  monBlocks = generateBlocks(tempMonSettings, monSettings.game.block.repeatRow, ...
    monSettings.game.block.repeatIndex, fillTrials);

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
    randomIdx = randperm(blockSettings.game.block.length, numSelect);
    blockSettings.game.trials = Data.blocks.planned{blockIdx}.trials(randomIdx, :);
    Data = runBlock(Data, blockSettings);
  end
end

% Close window
Screen('CloseAll');
end
