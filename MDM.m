function [ Data ] = MDM(subjectId)
% Main task script for the medical & monetary decision-making task (MDM).
%
% Loads config and DataObject, generates and executes requisite blocks, and
% records data for the subject whose `subjectId` is passed as an argument.
%
% If `subjectId` is not given, the task runs a shorter practice version of
% itself.
%
% Args:
%   subjectId (int, optional): A participant ID
%
% Returns:
%   DataObject struct: A `DataObject` with a record of the participant's
%   choices.
%
% Note:
%   Like RA, MDM utilizes the risk-and-ambiguity framework; unlike RA, it
%   displays symbols for its payoffs. (Historically, the task scripts developed
%   together.)
%

addpath(genpath('./lib')); % Add subfolders we'll be using to path
addpath(genpath('./tasks/MDM'));
% NOTE: genpath gets the directory and all its subdirectories

%% Setup
config = MDM_blockDefaults();
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
monConfig = MDM_monetaryConfig(config);
medConfig = MDM_medicalConfig(config);

%% Generate trials if not generated already
if ~isfield(Data, 'blocks') || isempty(Data.blocks)
  % MDM uses a particular set of trials, so we have to generate some trials
  % manually. Luckily, these can be shared across both kinds of blocks two
  % tasks, as their value range is equal. If that were not the case, they would
  % need to be disambiguated.

  % 1. Generate 1 repeat of reference level trials, all possible P/A values
  tempLevels = medConfig.trial.generate;
  tempLevels.stakes = tempLevels.reference;
  tempLevels.repeats = 1;
  fillTrials = generateTrials(tempLevels);
  % fillTrials = fillTrials(randperm(height(fillTrials), 4), :)

  % 2. Generate 2 additional trials with reference payoff
  tempLevels = medConfig.trial.generate;
  tempLevels.stakes = tempLevels.reference;
  tempLevels.probs = 0.25;
  tempLevels.ambigs = 0.5;
  tempLevels.repeats = 1;
  fillTrials = [fillTrials; generateTrials(tempLevels)];
  % fillTrials = fillTrials(randperm(height(fillTrials), 2), :)

  % 3. Have generateBlocks create the standard number of repeats with
  %    non-reference values
  tempMedConfig = medConfig;
  tempMedConfig.trial.generate.stakes = medConfig.trial.generate.stakes(2:end);
  medBlocks = generateBlocks(tempMedConfig, medConfig.trial.generate.catchTrial, ...
    medConfig.trial.generate.catchIdx, fillTrials);

  tempMonConfig = monConfig;
  tempMonConfig.trial.generate.stakes = monConfig.trial.generate.stakes(2:end);
  monBlocks = generateBlocks(tempMonConfig, monConfig.trial.generate.catchTrial, ...
    monConfig.trial.generate.catchIdx, fillTrials);

  % 4. Determine and save the order of blocks
  lastDigit = mod(Data.subjectId, 10);
  medFirst = ismember(lastDigit, [1, 2, 5, 6, 9]);
  medIdx = [1 1 0 0];
  if ~medFirst
    medIdx = 1 - medIdx; % flip
  end

  numBlocks = length(medIdx);
  Data.numFinishedBlocks = 0;
  for blockIdx = 1:numBlocks
    blockKind = medIdx(blockIdx);
    withinKindIdx = sum(medIdx(1 : blockIdx) == blockKind);
    if blockKind == 1
      Data = addGeneratedBlock(Data, medBlocks{withinKindIdx}, medConfig);
    else
      Data = addGeneratedBlock(Data, monBlocks{withinKindIdx}, monConfig);
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
  practiceBlocks = 2:3;
  numSelect = 3;
  Data = preparePractice(Data, practiceBlocks, numSelect);
  [ firstBlockIdx, lastBlockIdx ] = getBlocksForPractice(practiceBlocks);
end

for blockIdx = firstBlockIdx:lastBlockIdx
  Data = runNthBlock(Data, blockIdx);
end

% Close window
Screen('CloseAll');
end
