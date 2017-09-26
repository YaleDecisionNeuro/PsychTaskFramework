function [ Data ] = SODM(subjectId)
% Runs a self-other monetary and medical decision-making task and records
% its results for the subject whose subject number is passed in. Modeled on
% (and largely copy-pasted from) RA.m, to test out image implementation (#5).

addpath(genpath('./lib'));
addpath(genpath('./tasks/SODM'));
addpath('./tasks/MDM');
% Add subfolders we'll be using to path
% NOTE: genpath gets the directory and all its subdirectories

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

% Disambiguate config here
monConfig = SODM_monetaryConfig(config);
medConfig = SODM_medicalConfig(config);

%% Generate trials if not generated already
if ~isfield(Data, 'blocks') || isempty(Data.blocks)
  % NOTE: Generating each one separately with two repeats, so that there isn't
  % a cluster of high values in self vs. other
  medSelfBlocks = generateBlocks(medConfig, medConfig.trial.generate.catchTrial, ...
    medConfig.trial.generate.catchIdx);
  medOtherBlocks = generateBlocks(medConfig, medConfig.trial.generate.catchTrial, ...
    medConfig.trial.generate.catchIdx);
  monSelfBlocks = generateBlocks(monConfig, monConfig.trial.generate.catchTrial, ...
    monConfig.trial.generate.catchIdx);
  monOtherBlocks = generateBlocks(monConfig, monConfig.trial.generate.catchTrial, ...
    monConfig.trial.generate.catchIdx);

  medBlocks = [medSelfBlocks; medOtherBlocks];
  monBlocks = [monSelfBlocks; monOtherBlocks];

  sortOrder = mod(Data.subjectId, 4);
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
  beneficiaryLookup = {'Friend', 'Self'};

  % Logic: Do mon/med blocks first, pass self/other to them depending on selfIdx
  numBlocks = length(selfIdx);
  Data.numFinishedBlocks = 0;
  for blockIdx = 1:numBlocks
    blockKind = medIdx(blockIdx);
    beneficiaryKind = selfIdx(blockIdx);
    beneficiaryStr = beneficiaryLookup{beneficiaryKind + 1};
    withinKindIdx = sum(medIdx(1 : blockIdx) == blockKind);

    if blockKind == 1
      medConfig.runSetup.conditions.beneficiary = beneficiaryStr;
      Data = addGeneratedBlock(Data, medBlocks{withinKindIdx}, medConfig);
    else
      monConfig.runSetup.conditions.beneficiary = beneficiaryStr;
      Data = addGeneratedBlock(Data, monBlocks{withinKindIdx}, monConfig);
    end
  end
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

% Display "Currently evaluating a [description] trial" (see preBlock.m)
% disp('Currently Evaluating Random Trials')

% Evaluate Lottery for randomly chosen trial
SODM_pickTrials(Data)

% Close window
unloadPTB(monConfig, medConfig);
end
