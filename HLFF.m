function [ Data ] = HLFF(observer)
% HLFF Runs the high-/low-fat food task designed by Sarah Healy.

%% 1. Add subfolders we'll be using to path
addpath(genpath('./lib'));
addpath(genpath('./tasks/HLFF'));

settings = HLFF_config();
settings = loadPTB(settings);

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
  observer = NaN;
  Data.observer = NaN;
  settings.perUser.refSide = randi(2);
  settings.device.saveAfterBlock = false;
  settings.device.saveAfterTrial = false;
end

settingsLF = HLFF_config_LF(settings);
settingsHF = HLFF_config_HF(settings);
settingsLF.textures = loadTexturesFromConfig(settingsLF);
settingsHF.textures = loadTexturesFromConfig(settingsHF);
settingsMon = HLFF_config_monetary(settings);

%% Generate trials/blocks - if they haven't been generated before
% NOTE: If the number of generated trials changes, settings.game.block.numBlocks
%   will need to be changed to an integer that divides the generated trial count.
numBlocks = settings.game.block.numBlocks;
if ~isfield(Data, 'blocks') || ~isfield(Data.blocks, 'planned')
  blocksMon = generateBlocks(settingsMon);
  blocksLF = generateBlocks(settingsLF);
  blocksHF = generateBlocks(settingsHF);

  Data.blocks.planned = cell(numBlocks, 1);
  Data.blocks.recorded = cell(0);
  Data.blocks.numRecorded = 0;

  % Only counterbalance order for the food trials
  LFFirst = [1 1 0 0];
  if mod(observer, 2) == 0
    LFFirst = 1 - LFFirst;
  end

  for blockIdx = 1:numBlocks
    if blockIdx <= 2
      trialsToAdd = blocksMon{blockIdx};
      blockKind = 'Monetary';
    else
      blockIsLF = LFFirst(blockIdx - 2);
      addBlockIdx = mod(blockIdx, 2) + 1; % FIXME: ugly hack?
      if blockIsLF
        trialsToAdd = blocksLF{addBlockIdx};
        blockKind = 'LF';
      else
        trialsToAdd = blocksHF{addBlockIdx};
        blockKind = 'HF';
      end
    end
    Data.blocks.planned{blockIdx} = struct('trials', trialsToAdd, ...
      'blockKind', blockKind);
  end
end

% Display blocks
firstBlockIdx = Data.blocks.numRecorded + 1;
lastBlockIdx = numBlocks;

for blockIdx = firstBlockIdx:lastBlockIdx
  trialsToRun = Data.blocks.planned{blockIdx}.trials;
  blockKind = Data.blocks.planned{blockIdx}.blockKind;
  if isnan(observer)
    % Run practice -- random `numSelect` trials of each block type
    % Skip every even block
    if mod(blockIdx, 2) == 0
      continue;
    end
    numSelect = 3;
    randomIdx = randperm(height(trialsToRun), numSelect);
    trialsToRun = trialsToRun(randomIdx, :);
  end

  % Assign config
  switch(blockKind)
    case 'Monetary'
      config = settingsMon;
    case 'LF'
      config = settingsLF;
    case 'HF'
      config = settingsHF;
  end
  config.game.trials = trialsToRun;
  Data = runBlock(Data, config);
end

unloadPTB(settingsLF, settingsHF);
end
