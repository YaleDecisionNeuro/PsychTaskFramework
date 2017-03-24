function [ Data ] = UVRA(subjectId)
% UVRA Task script for a monetary R&A task with relaxed test-taking conditions.
%   ("U" stands for "unlimited", "V" for vertical layout of the choices.)
%
% Like all main tasks scripts, this function loads settings, executes requisite
%   blocks, and records data for the subject whose ID is passed as an argument.

%% Add subfolders we'll be using to path
addpath(genpath('./lib'));
addpath(genpath('./tasks/UVRA'));
% NOTE: genpath gets the directory and all its subdirectories

%% Setup
settings = UVRA_config();
settings = loadPTB(settings);

if exist('subjectId', 'var') % Running actual trials -> record
  % Find-or-create subject data file *in appropriate location*
  fname = [num2str(subjectId) '.mat'];
  folder = fullfile(settings.task.taskPath, 'data');
  fname = [folder filesep fname];
  [ Data, subjectExisted ] = loadOrCreate(subjectId, fname);

  if subjectExisted
    disp('Subject file exists, reusing...')
  else
    disp('Subject has no file, creating...')
    Data.date = datestr(now, 'yyyymmddTHHMMSS');
  end

  % Save subject ID + date
  % TODO: Prompt for correctness before launching PTB?
  Data.subjectId = subjectId;
  Data.lastAccess = datestr(now, 'yyyymmddTHHMMSS');
  if mod(subjectId, 2) == 0
      settings.runSetup.refSide = 1;
  else
      settings.runSetup.refSide = 2;
  end
else % Running practice
  Data.subjectId = NaN;
  settings.runSetup.refSide = randi(2);
  settings.device.saveAfterBlock = false;
  settings.device.saveAfterTrial = false;
end

%% Generate trials/blocks - if they haven't been generated before
% NOTE: If the number of generated trials changes, settings.task.numBlocks
%   will need to be changed to an integer that divides the generated trial count.
if ~isfield(Data, 'blocks') || ~isfield(Data.blocks, 'planned')
  blocks = generateBlocks(settings);
  numBlocks = settings.task.numBlocks;
  Data.plannedBlocks = cell(numBlocks, 1);
  Data.blocks.recorded = cell(0);
  Data.numFinishedBlocks = 0;
  for blockIdx = 1:numBlocks
    Data.plannedBlocks{blockIdx} = struct('trials', blocks{blockIdx});
  end
end

%% Display blocks
% Strategy: Run each block with separate settings; define its trials by
% subsetting them; handle any prompts / continuations here, or pass different
% callbacks
firstBlockIdx = Data.numFinishedBlocks + 1;
if firstBlockIdx > 3
  lastBlockIdx = 6;
else
  lastBlockIdx = 3;
end

if exist('subjectId', 'var')
  for blockIdx = firstBlockIdx:lastBlockIdx
    settings.runSetup.trialsToRun = Data.plannedBlocks{blockIdx}.trials;
    Data = runBlock(Data, settings);
  end
else
  % Run practice -- random `numSelect` trials of a random block
  numSelect = 3;
  blockIdx = randi(settings.task.numBlocks);
  randomIdx = randperm(settings.task.blockLength, numSelect);
  settings.runSetup.trialsToRun = Data.plannedBlocks{blockIdx}.trials(randomIdx, :);
  Data = runBlock(Data, settings);
end

unloadPTB(settings);
end
