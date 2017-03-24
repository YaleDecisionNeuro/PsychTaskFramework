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

  numBlocks = 8;
  Data.blocks.planned = cell(numBlocks, 1);
  Data.blocks.recorded = cell(0);
  Data.blocks.numRecorded = 0;
  for blockIdx = 1:numBlocks
    blockKind = gainsIdx(blockIdx);
    withinKindIdx = sum(gainsIdx(1 : blockIdx) == blockKind);
    if blockKind == 1
      Data.blocks.planned{blockIdx} = struct('trials', ...
        gainBlocks{withinKindIdx}, 'blockKind', blockKind);
    else
      Data.blocks.planned{blockIdx} = struct('trials', ...
        lossBlocks{withinKindIdx}, 'blockKind', blockKind);
    end
  end
end

%% Display blocks
% Strategy: Run each block with separate settings; define its trials by
% subsetting them; handle any prompts / continuations here, or pass different
% callbacks
firstBlockIdx = Data.blocks.numRecorded + 1;
if firstBlockIdx > 4
  lastBlockIdx = 8;
else
  lastBlockIdx = 4;
end
% NOTE: Incidentally, this takes care of an attempt to run more than 8 blocks -
%   9:8 is empty, so the for loop will not run if firstBlockIdx > lastBlockIdx

if exist('subjectId', 'var')
  for blockIdx = firstBlockIdx:lastBlockIdx
    if Data.blocks.planned{blockIdx}.blockKind == 0
      blockSettings = lossSettings;
    else
      blockSettings = gainSettings;
    end
    blockSettings.game.trials = Data.blocks.planned{blockIdx}.trials;
    Data = runBlock(Data, blockSettings);
  end
else
  % Run practice -- only first n trials of first two blocks?
  numSelect = 3;
  for blockIdx = 6:7 % Known to be two different blocks
    if Data.blocks.planned{blockIdx}.blockKind == 0
      blockSettings = lossSettings;
    else
      blockSettings = gainSettings;
    end
    randomIdx = randperm(blockSettings.task.blockLength, numSelect);
    blockSettings.game.trials = Data.blocks.planned{blockIdx}.trials(randomIdx, :);
    Data = runBlock(Data, blockSettings);
  end
end

unloadPTB(lossSettings, gainSettings);
% NOTE: could also just use settings, because neither windowPtr nor textures
%   were opened by the configs separately
end
