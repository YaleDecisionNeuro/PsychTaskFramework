function [ Data ] = MDM(subjectId)
% MDM Runs a medical decision-making task and records its results for the
%   subject whose subject number is passed in. Modeled on (and largely
%   copy-pasted from) RA.m, to test out image implementation (#5).

%% Add subfolders we'll be using to path
addpath(genpath('./lib'));
addpath(genpath('./tasks/MDM'));
% NOTE: genpath gets the directory and all its subdirectories

%% Setup
settings = MDM_config();
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

% Disambiguate settings here
monSettings = MDM_monetaryConfig(settings);
medSettings = MDM_medicalConfig(settings);
medSettings.runSetup.textures = loadTexturesFromConfig(medSettings);
monSettings.runSetup.textures = loadTexturesFromConfig(monSettings);

%% Generate trials if not generated already
if ~isfield(Data, 'blocks') || ~isfield(Data.blocks, 'planned')
  % MDM uses a particular set of trials, so we have to generate some trials
  % manually. Luckily, these can be shared across both kinds of blocks two
  % tasks, as their value range is equal. If that were not the case, they would
  % need to be disambiguated.

  % 1. Generate 1 repeat of reference level trials, all possible P/A values
  tempLevels = medSettings.trial.generate;
  tempLevels.stakes = tempLevels.reference;
  tempLevels.repeats = 1;
  fillTrials = generateTrials(tempLevels);
  % fillTrials = fillTrials(randperm(height(fillTrials), 4), :)

  % 2. Generate 2 additional trials with reference payoff
  tempLevels = medSettings.trial.generate;
  tempLevels.stakes = tempLevels.reference;
  tempLevels.probs = 0.25;
  tempLevels.ambigs = 0.5;
  tempLevels.repeats = 1;
  fillTrials = [fillTrials; generateTrials(tempLevels)];
  % fillTrials = fillTrials(randperm(height(fillTrials), 2), :)

  % 3. Have generateBlocks create the standard number of repeats with
  %    non-reference values
  tempMedSettings = medSettings;
  tempMedSettings.trial.generate.stakes = medSettings.trial.generate.stakes(2:end);
  medBlocks = generateBlocks(tempMedSettings, medSettings.trial.generate.catchTrial, ...
    medSettings.trial.generate.catchIdx, fillTrials);

  tempMonSettings = monSettings;
  tempMonSettings.trial.generate.stakes = monSettings.trial.generate.stakes(2:end);
  monBlocks = generateBlocks(tempMonSettings, monSettings.trial.generate.catchTrial, ...
    monSettings.trial.generate.catchIdx, fillTrials);

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
      Data = addGeneratedBlock(Data, medBlocks{withinKindIdx}, medSettings);
    else
      Data = addGeneratedBlock(Data, monBlocks{withinKindIdx}, monSettings);
    end
  end
end

% Display blocks
[ firstBlockIdx, lastBlockIdx ] = getBlocksForSession(Data);

if exist('subjectId', 'var')
  for blockIdx = firstBlockIdx:lastBlockIdx
    Data = runNthBlock(Data, blockIdx);
  end
else
  % Run practice -- only first n trials of first two blocks?
  numSelect = 3;
  practiceBlocks = 2:3; % Known to be two different blocks
  Data = preparePractice(Data, practiceBlocks, numSelect);
  for blockIdx = 1:length(practiceBlocks)
    Data = runNthBlock(Data, blockIdx);
  end
end

% Close window
Screen('CloseAll');
end
