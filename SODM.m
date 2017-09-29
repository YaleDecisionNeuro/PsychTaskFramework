function [ Data ] = SODM(subjectId)
% Runs a self-other monetary and medical decision-making task and records
% its results for the subject whose subject number is passed in. Modeled on
% (and largely copy-pasted from) RA.m, to test out image implementation (#5).

addpath(genpath('./lib'));
addpath(genpath('./tasks/SODM'));
% Add subfolders we'll be using to path

%% Load config
config = SODM_blockDefaults();
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

%% Generate trials if not generated already
if ~isfield(Data, 'blocks') || isempty(Data.blocks)
  Data.blocks = SODM_generateBlocks(subjectId, config);
end

% Select which blocks to run
if ~isnan(subjectId)
  [ firstBlockIdx, lastBlockIdx ] = getBlocksForSession(Data);
else
  % Gut the generated blocks to be limited to practice
  % TODO: Set this in config
  practiceBlocks = 1:4;
  numSelect = 3;
  Data = preparePractice(Data, practiceBlocks, numSelect);
  [ firstBlockIdx, lastBlockIdx ] = getBlocksForPractice(practiceBlocks);
end

% Run the blocks
for blockIdx = firstBlockIdx:lastBlockIdx
  Data = runNthBlock(Data, blockIdx);
end

% Close window
unloadPTB(config);
end
