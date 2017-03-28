function [ Data ] = HLFF(subjectId)
% HLFF Runs the high-/low-fat food task designed by Sarah Healy.

%% 1. Add subfolders we'll be using to path
addpath(genpath('./lib'));
addpath(genpath('./tasks/HLFF'));

settings = HLFF_config();
settings = loadPTB(settings);

if exist('subjectId', 'var') % Running actual trials -> record
  % Find-or-create subject data file *in appropriate location*
  fname = [num2str(subjectId) '.mat'];
  folder = fullfile(settings.task.taskPath, 'data');
  fname = [folder filesep fname];
  [ Data, subjectExisted ] = loadOrCreate(subjectId, fname);

  % TODO: Prompt experimenter if this is correct
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

settingsLF = HLFF_config_LF(settings);
settingsLF.runSetup.textures = loadTexturesFromConfig(settingsLF);

%% Generate trials/blocks - if they haven't been generated before
% NOTE: If the number of generated trials changes, settings.task.numBlocks
%   will need to be changed to an integer that divides the generated trial count.
if ~isfield(Data, 'planned')
  blocks = generateBlocks(settingsLF);
  numBlocks = settingsLF.task.numBlocks;
  Data.numFinishedBlocks = 0;
  for blockIdx = 1:numBlocks
    Data = addGeneratedBlock(Data, blocks{blockIdx}, settingsLF);
  end
end

% Display blocks
firstBlockIdx = Data.numFinishedBlocks + 1;
lastBlockIdx = 2; % FIXME: Derive from settings

if exist('subjectId', 'var')
  for blockIdx = firstBlockIdx:lastBlockIdx
    Data = runNthBlock(Data, blockIdx);
  end
else
  % Run practice -- random `numSelect` trials of a random block
  numSelect = 3;
  randomIdx = randperm(settingsLF.task.blockLength, numSelect);
  Data.blocks{1}.trials = Data.blocks{1}.trials(randomIdx, :);
  Data = runNthBlock(Data, 1);
end

unloadPTB(settingsLF);
end
