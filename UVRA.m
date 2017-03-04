function [ Data ] = UVRA(observer)
% UVRA Task script for a monetary R&A task with relaxed test-taking conditions.
%   ("U" stands for "unlimited", "V" for vertical layout of the choices.)
%
% Like all main tasks scripts, this function loads settings, executes requisite
%   blocks, and records data for the subject whose ID is passed as an argument.

%% Add subfolders we'll be using to path
addpath(genpath('./lib'));
addpath(genpath('./tasks/RA'));
addpath(genpath('./tasks/UVRA'));
% NOTE: genpath gets the directory and all its subdirectories

%% Setup
settings = UVRA_config();
KbName(settings.device.KbName);

% Set random generator
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

%% Set up window
% TODO: Conditional on provided `settings.device.screenDims`?
[settings.device.windowPtr, settings.device.screenDims] = ...
  Screen('OpenWindow', settings.device.screenId, ...
  settings.default.bgrColor);

%% Generate trials/blocks - if they haven't been generated before
% NOTE: If the number of generated trials changes, this section will require
%   a manual rewrite.
if ~isfield(Data, 'blocks') || ~isfield(Data.blocks, 'planned')
  blocks = generateBlocks(settings);
  numBlocks = settings.game.block.numBlocks;
  Data.blocks.planned = cell(numBlocks, 1);
  Data.blocks.recorded = cell(0);
  Data.blocks.numRecorded = 0;
  for blockIdx = 1:numBlocks
    Data.blocks.planned{blockIdx} = struct('trials', blocks{blockIdx});
  end
end

%% Display blocks
% Strategy: Run each block with separate settings; define its trials by
% subsetting them; handle any prompts / continuations here, or pass different
% callbacks
%
% TODO: Is this the right block division for this task?
firstBlockIdx = Data.blocks.numRecorded + 1;
if firstBlockIdx > 3
  lastBlockIdx = 6;
else
  lastBlockIdx = 3;
end

if exist('observer', 'var')
  for blockIdx = firstBlockIdx:lastBlockIdx
    settings.game.trials = Data.blocks.planned{blockIdx}.trials;
    Data = runBlock(Data, settings);
  end
else
  % Run practice -- random `numSelect` trials of a random block
  numSelect = 3;
  blockIdx = randi(settings.game.block.numBlocks);
  randomIdx = randperm(settings.game.block.length, numSelect);
  settings.game.trials = Data.blocks.planned{blockIdx}.trials(randomIdx, :);
  Data = runBlock(Data, settings);
end

Screen('CloseAll');
end
