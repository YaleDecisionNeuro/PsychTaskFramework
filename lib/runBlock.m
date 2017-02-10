function Data = runBlock(Data, blockSettings)
  % RUNBLOCK Scaffolds multiple trial calls of the same kind and saves the file
  %   after al of them have run.
  %
  % The main thing `runBlock` needs from blockSettings is for `.game.trialFn`
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

  %% 1. If settings say so, run pre-block callback (e.g. display title)
  if isfield(blockSettings.game, 'preBlockFn')
    blockSettings.game.preBlockFn(Data, blockSettings);
  end

  %% 2. Iterate through trials
  trials = blockSettings.game.trials;
  numTrials = size(trials, 1);

  drawTrial = blockSettings.game.trialFn;
  if ~isa(drawTrial, 'function_handle')
    error(['Function to draw trials not supplied! Make sure that you''ve set' ...
      ' settings.game.trialFn = @your_function_to_draw_trials']);
  end

  collectedData = [];
  for i = 1:numTrials
    trialSettings = trials(i, :);
    trialData = drawTrial(trialSettings, blockSettings);
    trialRecord = [trialSettings struct2table(trialData)];
    collectedData = appendRow(trialRecord, ...
      collectedData);
  end

  %% 3. Save participant file after block
  Data = addBlock(Data, collectedData, blockSettings);
  saveData(Data);

  %% 4. If settings say so, run post-block callback
  if isfield(blockSettings.game, 'postBlockFn')
    blockSettings.game.postBlockFn(Data, blockSettings);
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

function [ DataObject ] = addBlock(DataObject, blockData, blockSettings)
% ADDBLOCK Appends `blockData` to the cell array `DataObject.recordedBlocks`.
%   Stores records in `.records` and the settings used for the block in
%   `.settings`.

  if ~isfield(DataObject, 'recordedBlocks')
    DataObject.recordedBlocks = cell(0);
    n = 1;
  else
    n = length(DataObject.recordedBlocks) + 1;
  end

  DataObject.recordedBlocks{n}.records = blockData;
  DataObject.recordedBlocks{n}.settings = blockSettings;
end
