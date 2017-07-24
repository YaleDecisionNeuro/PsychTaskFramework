function Data = runBlock(Data, blockConfig)
  % Scaffolds multiple trial calls of the same kind and saves the file
  %   after all of them have run.
  %
  % The main thing `runBlock` needs from blockConfig is for `.task.fnHandles.trialFn`
  %   to be a function handle to which it can pass Data, trial #, and blockConfig.
  %
  % If `blockConfig.game` includes fields `preBlockFn` and/or `postBlockFn`,
  %   it will assume they are callable functions and call them with `Data` and
  %   `blockConfig` as arguments. (This means they can display block beginning
  %   / end and wait for keypress, or check if requisite values exist and fail
  %   gracefully, or any number of other things.)
  %
  % If `Data.filename` does not exist, it will not know how to save the trial
  %   choices (and will issue a warning).
  %
  % Args:
  %   Data: Information collected from task trials
  %   blockConfig: The block settings
  %
  % Returns:
  %   Data: Information collected from task trials.

  %% 0. Validate the DataObject
  Data = prepForRecording(Data);

  %% 1. If config say so, run pre-block callback (e.g. display title)
  if isfield(blockConfig.task.fnHandles, 'preBlockFn') && ...
     isa(blockConfig.task.fnHandles.preBlockFn, 'function_handle')
    blockConfig.task.fnHandles.preBlockFn(Data, blockConfig);
  end

  %% 2. Iterate through trials
  trials = blockConfig.runSetup.trialsToRun;
  numTrials = size(trials, 1);
  firstTrial = getFirstTrial(Data);

  runTrialFn = blockConfig.task.fnHandles.trialFn;
  if ~isa(runTrialFn, 'function_handle')
    error(['Function to draw trials not supplied! Make sure that you''ve set' ...
      ' config.task.fnHandles.trialFn = @your_function_to_draw_trials']);
  end

  for k = firstTrial : numTrials
    trialData = trials(k, :);
    trialData = runTrialFn(trialData, blockConfig);
    Data = addTrial(Data, trialData, blockConfig);
    if blockConfig.device.saveAfterTrial
      saveData(Data);
    end
  end

  %% 3. Save subject file after block
  Data = finishBlock(Data);
  if blockConfig.device.saveAfterBlock || blockConfig.device.saveAfterTrial
    saveData(Data);
  end

  %% 4. If config say so, run post-block callback
  if isfield(blockConfig.task.fnHandles, 'postBlockFn') && ...
     isa(blockConfig.task.fnHandles.postBlockFn, 'function_handle')
    blockConfig.task.fnHandles.postBlockFn(Data, blockConfig);
  end
end

%% Helper functions
function [ tbl ] = appendRow(row, tbl)
% If `tbl` is defined, add `row` and return it; otherwise, just
%   make `row` the new contents of `tbl`.
%
% Args:
%   row: A single line of a table
%   tbl: A table composed of a row or rows
%
% Returns:
%   tbl: A table composed of a row or rows.

  if isempty(tbl)
    tbl = row;
  else
    tbl = [tbl; row]; % will scream if table and row have different columns
  end
end

function [ DataObject ] = addTrial(DataObject, trialData, blockConfig)
% Adds `trialData` to the latest incomplete block record in DataObject.
%
% Assumes that prepForRecording already ran on the DataObject.
%
% Args:
%   DataObject: An object containing information (on blocks)
%   trialData: Information gathered from a trial
%   blockConfig: The block settings
%
% Returns:
%   DataObject: An object containing information (on blocks).

% Get the index of the current block being recorded
currentBlockIdx = DataObject.numFinishedBlocks + 1;

% If the block is new, set it up with current config
if numel(DataObject.blocks.recorded) < currentBlockIdx
  DataObject.blocks.recorded{currentBlockIdx} = struct;
  DataObject.blocks.recorded{currentBlockIdx}.config = blockConfig;
  DataObject.blocks.recorded{currentBlockIdx}.records  = [];
end

% Add trialData to the DataObject
DataObject.blocks.recorded{currentBlockIdx}.records = appendRow(trialData, ...
  DataObject.blocks.recorded{currentBlockIdx}.records);
end

function [ DataObject ] = finishBlock(DataObject)
% Mark that the block is finished and shouldn't be resumed.
%
% Args: 
%   DataObject: An object containing information (on blocks)
%
% Returns:
%   DataObject: An object containing information (on blocks).

  DataObject.numFinishedBlocks = DataObject.numFinishedBlocks + 1;
end

function [ DataObject ] = prepForRecording(DataObject)
% Ensure that DataObject has the fields it is expected to have.
%
% Args:
%   DataObject: An object containing information (on blocks)
%
% Returns:
%   DataObject: An object containing information (on blocks).

  if ~isfield(DataObject, 'numFinishedBlocks')
    DataObject.numFinishedBlocks = 0;
  end
  if ~isfield(DataObject.blocks, 'recorded')
    DataObject.blocks.recorded = cell(0);
  end
end

function [ firstTrial ] = getFirstTrial(DataObject)
% Determine the first trial to run if the block was previously interrupted.
%
% Args:
%   DataObject: An object containing information (on blocks)
%
% Returns: 
%   firstTrial: The trial to start with when beginning a block or continuing in a partially completed block.  

numStartedBlocks = numel(DataObject.blocks.recorded);
numFinishedBlocks = DataObject.numFinishedBlocks;

if numStartedBlocks > numFinishedBlocks
  firstTrial = height(DataObject.blocks.recorded{end}.records) + 1;
else
  firstTrial = 1;
end
end
