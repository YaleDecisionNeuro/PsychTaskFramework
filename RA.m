function [ Data ] = RA(subjectId)
% RA Main task script for the monetary risk and ambiguity task. Loads settings,
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
settings = RA_config();
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
gainSettings = settings;
lossSettings = RA_Loss_config(gainSettings);

%% Generate trials/blocks - if they haven't been generated before
if ~isfield(Data, 'blocks') || ~isfield(Data.blocks, 'planned')
  % Gains
  gainBlocks = generateBlocks(gainSettings, gainSettings.trial.generate.catchTrial, ...
    gainSettings.trial.generate.catchIdx);

  % Losses
  lossBlocks = generateBlocks(lossSettings, lossSettings.trial.generate.catchTrial, ...
    lossSettings.trial.generate.catchIdx);

  lastDigit = mod(Data.subjectId, 10);
  gainsFirst = ismember(lastDigit, [1, 2, 5, 6, 9]);
  gainsIdx = [1 1 0 0 0 0 1 1];
  if ~gainsFirst
    gainsIdx = 1 - gainsIdx; % flip
  end

  numBlocks = settings.task.numBlocks;
  Data.numFinishedBlocks = 0;
  for blockIdx = 1:numBlocks
    blockKind = gainsIdx(blockIdx);
    withinKindIdx = sum(gainsIdx(1 : blockIdx) == blockKind);
    if blockKind == 1
      Data = addGeneratedBlock(Data, gainBlocks{withinKindIdx}, gainSettings);
    else
      Data = addGeneratedBlock(Data, lossBlocks{withinKindIdx}, lossSettings);
    end
  end
end

%% Display blocks
% Strategy: Run each block with separate settings; define its trials by
% subsetting them; handle any prompts / continuations here, or pass different
% callbacks
[ firstBlockIdx, lastBlockIdx ] = getBlocksForSession(Data);

if exist('subjectId', 'var')
  for blockIdx = firstBlockIdx:lastBlockIdx
    Data = runNthBlock(Data, blockIdx);
  end
else
  % Run practice -- only first n trials of first two blocks?
  numSelect = 3;
  practiceBlocks = 6:7; % Known to be two different blocks
  Data.blocks = Data.blocks(practiceBlocks);
  for blockIdx = 1:length(practiceBlocks)
    blockLength = height(Data.blocks{blockIdx}.trials);
    randomIdx = randperm(blockLength, numSelect);
    Data.blocks{blockIdx}.trials = Data.blocks{blockIdx}.trials(randomIdx, :);
    Data = runNthBlock(Data, blockIdx);
  end
end

unloadPTB(lossSettings, gainSettings);
% NOTE: could also just use settings, because neither windowPtr nor textures
%   were opened by the configs separately
end
