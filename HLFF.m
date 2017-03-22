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
  Data.observer = NaN;
  settings.perUser.refSide = randi(2);
  settings.device.saveAfterBlock = false;
  settings.device.saveAfterTrial = false;
end

settingsLF = HLFF_config_LF(settings);
settingsLF.textures = loadTexturesFromConfig(settingsLF);

%% Generate trials/blocks - if they haven't been generated before
% NOTE: If the number of generated trials changes, settings.task.numBlocks
%   will need to be changed to an integer that divides the generated trial count.
if ~isfield(Data, 'blocks') || ~isfield(Data.blocks, 'planned')
  blocks = generateBlocks(settingsLF);
  numBlocks = settingsLF.task.numBlocks;
  Data.blocks.planned = cell(numBlocks, 1);
  Data.blocks.recorded = cell(0);
  Data.blocks.numRecorded = 0;
  for blockIdx = 1:numBlocks
    Data.blocks.planned{blockIdx} = struct('trials', blocks{blockIdx});
  end
end

% Display blocks
firstBlockIdx = Data.blocks.numRecorded + 1;
lastBlockIdx = 2; % FIXME: Derive from settings

if exist('observer', 'var')
  for blockIdx = firstBlockIdx:lastBlockIdx
    settingsLF.game.trials = Data.blocks.planned{blockIdx}.trials;
    Data = runBlock(Data, settingsLF);
  end
else
  % Run practice -- random `numSelect` trials of a random block
  numSelect = 3;
  blockIdx = randi(settingsLF.task.numBlocks);
  randomIdx = randperm(settingsLF.game.block.length, numSelect);
  settingsLF.game.trials = Data.blocks.planned{blockIdx}.trials(randomIdx, :);
  Data = runBlock(Data, settingsLF);
end

unloadPTB(settingsLF);
end
