function Data = runBlock(Data, blockSettings)
  % RUNBLOCK Scaffolds multiple trial calls of the same kind and saves the file
  %   after al of them have run.
  %
  % The main thing `runBlock` needs from blockSettings is for `.task.fnHandles.trialFn`
  % to be a function handle to which it can pass Data, trial #, and blockSettings.
  %
  % If `blockSettings.game` includes fields `preBlockFn` and/or `postBlockFn`,
  % it will assume they are callable functions and call them with `Data` and
  % `blockSettings` as arguments. (This means they can display block beginning
  % / end and wait for keypress, or check if requisite values exist and fail
  % gracefully, or any number of other things.)
  %
  % If `Data.filename` does not exist, it will not know how to save the trial
  % choices (and will issue a warning).

  %% 0. Validate the DataObject
  Data = prepForRecording(Data);

  %% 1. If settings say so, run pre-block callback (e.g. display title)
  if isfield(blockSettings.task.fnHandles, 'preBlockFn') && ...
     isa(blockSettings.task.fnHandles.preBlockFn, 'function_handle')
    blockSettings.task.fnHandles.preBlockFn(Data, blockSettings);
  end

  %% 2. Iterate through trials
  trials = blockSettings.game.trials;
  numTrials = size(trials, 1);
  firstTrial = getFirstTrial(Data);

  runTrialFn = blockSettings.task.fnHandles.trialFn;
  if ~isa(runTrialFn, 'function_handle')
    error(['Function to draw trials not supplied! Make sure that you''ve set' ...
      ' settings.task.fnHandles.trialFn = @your_function_to_draw_trials']);
  end

  for k = firstTrial : numTrials
    trialData = trials(k, :);
    trialData = runTrialFn(trialData, blockSettings);
    Data = addTrial(Data, trialData, blockSettings);
    if blockSettings.device.saveAfterTrial
      saveData(Data);
    end
  end

  %% 3. Save subject file after block
  Data = finishBlock(Data);
  if blockSettings.device.saveAfterBlock || blockSettings.device.saveAfterTrial
    saveData(Data);
  end

  %% 4. If settings say so, run post-block callback
  if isfield(blockSettings.task.fnHandles, 'postBlockFn') && ...
     isa(blockSettings.task.fnHandles.postBlockFn, 'function_handle')
    blockSettings.task.fnHandles.postBlockFn(Data, blockSettings);
  end
end

%% Helper functions
function [ tbl ] = appendRow(row, tbl)
% APPENDROW If `tbl` is defined, append `row` and return it; otherwise, just
%   make `row` the new contents of `tbl`.
  if isempty(tbl)
    tbl = row;
  else
    tbl = [tbl; row]; % will scream if table and row have different columns
  end
end

function [ DataObject ] = addTrial(DataObject, trialData, blockSettings)
% Appends `trialData` to the latest incomplete block record in DataObject.
%
% Assumes that prepForRecording already ran on the DataObject.

% Get the index of the current block being recorded
currentBlockIdx = DataObject.numFinishedBlocks + 1;

% If the block is new, set it up with current settings
if numel(DataObject.blocks.recorded) < currentBlockIdx
  DataObject.blocks.recorded{currentBlockIdx} = struct;
  DataObject.blocks.recorded{currentBlockIdx}.settings = blockSettings;
  DataObject.blocks.recorded{currentBlockIdx}.records  = [];
end

% Add trialData to the DataObject
DataObject.blocks.recorded{currentBlockIdx}.records = appendRow(trialData, ...
  DataObject.blocks.recorded{currentBlockIdx}.records);
end

function [ DataObject ] = finishBlock(DataObject)
% Mark that the block is finished and shouldn't be resumed.
  DataObject.numFinishedBlocks = DataObject.numFinishedBlocks + 1;
end

function [ DataObject ] = prepForRecording(DataObject)
% Ensure that DataObject has the fields it is expected to have.
  if ~isfield(DataObject, 'numFinishedBlocks')
    DataObject.numFinishedBlocks = 0;
  end
  if ~isfield(DataObject.blocks, 'recorded')
    DataObject.blocks.recorded = cell(0);
  end
end

function [ firstTrial ] = getFirstTrial(DataObject)
% Determine the first trial to run if the block was previously interrupted
numStartedBlocks = numel(DataObject.blocks.recorded);
numFinishedBlocks = DataObject.numFinishedBlocks;

if numStartedBlocks > numFinishedBlocks
  firstTrial = height(DataObject.blocks.recorded{end}.records) + 1;
else
  firstTrial = 1;
end
end
