function [ Data ] = HLFF(subjectId)
% HLFF Runs the high-/low-fat food task designed by Sarah Healy.

%% 1. Add subfolders we'll be using to path
addpath(genpath('./lib'));
addpath(genpath('./tasks/HLFF'));

config = HLFF_blockDefaults();
config = loadPTB(config);
if ~exist('subjectId', 'var') % Practice
  subjectId = NaN;
  config = setupPracticeConfig(config);
end

% Find-or-create subject data file *in appropriate location*
fname = [num2str(subjectId) '.mat'];
folder = fullfile(config.task.taskPath, 'data');
fname = [folder filesep fname];
[ Data, subjectExisted ] = loadOrCreate(subjectId, fname);

% TODO: Prompt experimenter if this is correct
if subjectExisted
  disp('Subject file exists, reusing...')
elseif ~isnan(subjectId)
  disp('Subject has no file, creating...')
end

if ~isnan(subjectId)
  if mod(subjectId, 2) == 0
      config.runSetup.refSide = 1;
  else
      config.runSetup.refSide = 2;
  end
end

configLF = HLFF_LFConfig(config);
configLF.runSetup.textures = loadTexturesFromConfig(configLF);

%% Generate trials/blocks - if they haven't been generated before
% NOTE: If the number of generated trials changes, config.task.numBlocks
%   will need to be changed to an integer that divides the generated trial count.
if ~isfield(Data, 'blocks') || isempty(Data.blocks)
  blocks = generateBlocks(configLF);
  numBlocks = configLF.task.numBlocks;
  Data.numFinishedBlocks = 0;
  for blockIdx = 1:numBlocks
    Data = addGeneratedBlock(Data, blocks{blockIdx}, configLF);
  end
end

% Display blocks
if ~isnan(subjectId)
  firstBlockIdx = Data.numFinishedBlocks + 1;
  lastBlockIdx = 2; % FIXME: Derive from config
else
  practiceBlocks = 1;
  numSelect = 3;
  Data = preparePractice(Data, practiceBlocks, numSelect);
  [ firstBlockIdx, lastBlockIdx ] = getBlocksForPractice(practiceBlocks);
end

for blockIdx = firstBlockIdx:lastBlockIdx
  Data = runNthBlock(Data, blockIdx);
end

unloadPTB(configLF);
end
