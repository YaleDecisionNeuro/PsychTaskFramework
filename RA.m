function [ Data ] = RA(subjectId)
% RA Main task script for the monetary risk and ambiguity task. Loads config,
%   executes requisite blocks, and records data for the subject whose ID is
%   passed as an argument.
%
% It bears noting that in its general outline, this script can be written to
% conduct any form of the trial -- all of RA_Practice, RA_Gains, and RA_Loss
% can be established here. (If you add logic for condition assignment and
% detection of past recorded trials, you'll be able to invoke this script with
% the same call for both sessions -- it will just keep adding the new data to
% `.recordedBlocks`).

%% Add subfolders we'll be using to path
addpath(genpath('./lib'));
addpath(genpath('./tasks/RA'));
% NOTE: genpath gets the directory and all its subdirectories

%% Setup
config = RA_blockDefaults();
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

% Disambiguate config here
gainConfig = config;
lossConfig = RA_lossConfig(gainConfig);

%% Generate trials/blocks - if they haven't been generated before
if ~isfield(Data, 'blocks') || isempty(Data.blocks)
  % Gains
  gainBlocks = generateBlocks(gainConfig, gainConfig.trial.generate.catchTrial, ...
    gainConfig.trial.generate.catchIdx);

  % Losses
  lossBlocks = generateBlocks(lossConfig, lossConfig.trial.generate.catchTrial, ...
    lossConfig.trial.generate.catchIdx);

  lastDigit = mod(Data.subjectId, 10);
  gainsFirst = ismember(lastDigit, [1, 2, 5, 6, 9]);
  gainsIdx = [1 1 0 0 0 0 1 1];
  if ~gainsFirst
    gainsIdx = 1 - gainsIdx; % flip
  end

  numBlocks = config.task.numBlocks;
  Data.numFinishedBlocks = 0;
  for blockIdx = 1:numBlocks
    blockKind = gainsIdx(blockIdx);
    withinKindIdx = sum(gainsIdx(1 : blockIdx) == blockKind);
    if blockKind == 1
      Data = addGeneratedBlock(Data, gainBlocks{withinKindIdx}, gainConfig);
    else
      Data = addGeneratedBlock(Data, lossBlocks{withinKindIdx}, lossConfig);
    end
  end
end

%% Display blocks
% Select which blocks to run
if ~isnan(subjectId)
  [ firstBlockIdx, lastBlockIdx ] = getBlocksForSession(Data);
else
  % Gut the generated blocks to be limited to practice
  % TODO: Set this in config
  practiceBlocks = 6:7;
  numSelect = 3;
  Data = preparePractice(Data, practiceBlocks, numSelect);
  [ firstBlockIdx, lastBlockIdx ] = getBlocksForPractice(practiceBlocks);
end

% Run the blocks
for blockIdx = firstBlockIdx:lastBlockIdx
  Data = runNthBlock(Data, blockIdx);
end

unloadPTB(lossConfig, gainConfig);
% NOTE: could also just use config, because neither windowPtr nor textures
%   were opened by the configs separately
end
