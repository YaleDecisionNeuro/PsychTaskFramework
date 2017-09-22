function [ Data ] = HLFF(subjectId)
% Task script for the high-/low-fat food task designed by Sarah Healy.
%
% Args:
%   subjectId (optional): A participant ID
%
% Returns:
%   Data: A record of the participant's choices.

addpath(genpath('./lib')); % 1. Add subfolders we'll be using to path
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
configHF = HLFF_HFConfig(config);
configHF.runSetup.textures = loadTexturesFromConfig(configHF);
configLF.runSetup.textures = loadTexturesFromConfig(configLF);
configMon = HLFF_monetaryConfig(config);

%% Generate trials/blocks - if they haven't been generated before
% NOTE: If the number of generated trials changes, config.task.numBlocks
%   will need to be changed to an integer that divides the generated trial count.
numBlocks = config.task.numBlocks;
if ~isfield(Data, 'blocks') || isempty(Data.blocks)
  blocksMon = generateBlocks(configMon, configMon.trial.generate.catchTrial, configMon.trial.generate.catchIdx);
  blocksLF =  generateBlocks(configLF, configLF.trial.generate.catchTrial, configLF.trial.generate.catchIdx);
  blocksHF =  generateBlocks(configHF, configHF.trial.generate.catchTrial, configHF.trial.generate.catchIdx);

  % Record these blocks for manual alteration
  % writetable(vertcat(blocksHF{:}),  'tasks\HLFF\trials\trials_HF.csv');
  % writetable(vertcat(blocksLF{:}),  'tasks\HLFF\trials\trials_LF.csv');
  % writetable(vertcat(blocksMon{:}), 'tasks\HLFF\trials\trials_monetary.csv');

  Data.numFinishedBlocks = 0;
  % Only counterbalance order for the food trials
  LFFirst = [1 1 0 0];
  if mod(subjectId, 2) == 0
    LFFirst = 1 - LFFirst;
  end

  for blockIdx = 1:numBlocks
    if blockIdx <= 2
      Data = addGeneratedBlock(Data, blocksMon{blockIdx}, configMon);
    else
      blockIsLF = LFFirst(blockIdx - 2);
      addBlockIdx = mod(blockIdx, 2) + 1; % FIXME: ugly hack?
      if blockIsLF
        Data = addGeneratedBlock(Data, blocksLF{addBlockIdx}, configLF);
      else
        Data = addGeneratedBlock(Data, blocksHF{addBlockIdx}, configHF);
      end
    end
  end
end

% Display blocks
if ~isnan(subjectId)
  [ firstBlockIdx, lastBlockIdx ] = getBlocksForSession(Data);
else
  practiceBlocks = [2 4 6];
  numSelect = 3;
  Data = preparePractice(Data, practiceBlocks, numSelect);
  [ firstBlockIdx, lastBlockIdx ] = getBlocksForPractice(practiceBlocks);
end

for blockIdx = firstBlockIdx:lastBlockIdx
  Data = runNthBlock(Data, blockIdx);
end

unloadPTB(configLF, configHF);
end
