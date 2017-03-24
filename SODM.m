function [ Data ] = SODM(observer)
% SODM Runs a self-other monetary and medical decision-making task and records
%   its results for the participant whose subject number is passed in. Modeled
%   on (and largely copy-pasted from) RA.m, to test out image implementation
%   (#5).

%% Add subfolders we'll be using to path
addpath(genpath('./lib'));
addpath(genpath('./tasks/SODM'));
addpath('./tasks/MDM');
% NOTE: genpath gets the directory and all its subdirectories

%% Load settings
settings = SODM_config();
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
monSettings = SODM_config_monetary(settings);
medSettings = SODM_config_medical(settings);
medSettings.runSetup.textures = loadTexturesFromConfig(medSettings);
monSettings.runSetup.textures = loadTexturesFromConfig(monSettings);

%% Generate trials if not generated already
if ~isfield(Data, 'blocks') || ~isfield(Data.blocks, 'planned')
  % NOTE: Generating each one separately with two repeats, so that there isn't
  % a cluster of high values in self vs. other
  medSelfBlocks = generateBlocks(medSettings, medSettings.trial.generate.catchTrial, ...
    medSettings.trial.generate.catchIdx);
  medOtherBlocks = generateBlocks(medSettings, medSettings.trial.generate.catchTrial, ...
    medSettings.trial.generate.catchIdx);
  monSelfBlocks = generateBlocks(monSettings, monSettings.trial.generate.catchTrial, ...
    monSettings.trial.generate.catchIdx);
  monOtherBlocks = generateBlocks(monSettings, monSettings.trial.generate.catchTrial, ...
    monSettings.trial.generate.catchIdx);

  medBlocks = [medSelfBlocks; medOtherBlocks];
  monBlocks = [monSelfBlocks; monOtherBlocks];

  sortOrder = mod(Data.observer, 4);
  selfIdx = [1 0 1 0]; % 0 is friend, 1 is self
  medIdx = [1 1 0 0];  % 0 is monetary, 1 is medical

  switch sortOrder
    case 0
      % Keep order
    case 1
      selfIdx = 1 - selfIdx;
    case 2
      medIdx = 1 - medIdx;
    case 3
      selfIdx = 1 - selfIdx;
      medIdx = 1 - medIdx;
  end
  % Repeat the order for the second round
  selfIdx = repmat(selfIdx, 1, 2);
  medIdx = repmat(medIdx, 1, 2);

  % Logic: Do mon/med blocks first, pass self/other to them depending on selfIdx
  numBlocks = 8; % TODO: Derive from settings?
  Data.blocks.planned = cell(numBlocks, 1);
  Data.blocks.recorded = cell(0);
  Data.blocks.numRecorded = 0;
  for blockIdx = 1:numBlocks
    blockKind = medIdx(blockIdx);
    beneficiaryKind = selfIdx(blockIdx);
    withinKindIdx = sum(medIdx(1 : blockIdx) == blockKind);

    if blockKind == 1
      Data.blocks.planned{blockIdx} = struct('trials', ...
        medBlocks{withinKindIdx}, 'blockKind', blockKind, ...
        'beneficiaryKind', beneficiaryKind);
    else
      Data.blocks.planned{blockIdx} = struct('trials', ...
        monBlocks{withinKindIdx}, 'blockKind', blockKind, ...
        'beneficiaryKind', beneficiaryKind);
    end
  end
end

% Display blocks
firstBlockIdx = Data.blocks.numRecorded + 1;
lastBlockIdx = 8; % FIXME: Derive from settings

if exist('observer', 'var')
  for blockIdx = firstBlockIdx:lastBlockIdx
    % Determine monetary or medical
    if Data.blocks.planned{blockIdx}.blockKind == 0
      blockSettings = monSettings;
    else
      blockSettings = medSettings;
    end

    % Determine self or other
    if Data.blocks.planned{blockIdx}.beneficiaryKind == 0
      blockSettings.game.block.beneficiaryKind = 0;
      blockSettings.game.block.beneficiaryText = 'Friend';
    else
      blockSettings.game.block.beneficiaryKind = 1;
      blockSettings.game.block.beneficiaryText = 'Myself';
    end
    blockSettings.runSetup.blockName = [blockSettings.runSetup.blockName ' / ' ...
      blockSettings.game.block.beneficiaryText];

    blockSettings.game.trials = Data.blocks.planned{blockIdx}.trials;
    Data = runBlock(Data, blockSettings);
  end
else
  % Run practice -- only first n trials of first two blocks?
  numSelect = 3;
  for blockIdx = 1:4
    % Determine medical or monetary
    if Data.blocks.planned{blockIdx}.blockKind == 0
      blockSettings = monSettings;
    else
      blockSettings = medSettings;
    end

    % Determine self or other
    if Data.blocks.planned{blockIdx}.beneficiaryKind == 0
      blockSettings.game.block.beneficiaryKind = 0;
      blockSettings.game.block.beneficiaryText = 'Friend';
    else
      blockSettings.game.block.beneficiaryKind = 1;
      blockSettings.game.block.beneficiaryText = 'Myself';
    end
    blockSettings.runSetup.blockName = [blockSettings.runSetup.blockName ' / ' ...
      blockSettings.game.block.beneficiaryText];

    randomIdx = randperm(blockSettings.task.blockLength, numSelect);
    blockSettings.game.trials = Data.blocks.planned{blockIdx}.trials(randomIdx, :);
    Data = runBlock(Data, blockSettings);
  end
end

% Close window
unloadPTB(monSettings, medSettings);
end
