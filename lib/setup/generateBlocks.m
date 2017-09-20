function plannedBlocks = generateBlocks(blockConfig, ...
    catchTrial, catchIdx, adHocTrials)
% Returns a cell array of trial tables within a block.
%
% Trial tables are generated with `generateTrials` from
% `blockConfig.trial.generate`, separated into blocks with a fixed number of rows
% (defined in `blockConfig.task.blockLength`). If given further arguments, it
% will also add to the final trial table the table `catchTrial` at per-block
% indices passed in `catchIdx`. If `adHocTrials` are provided, they are mixed
% in with the generated trials prior to randomization and separation into
% blocks.
%
% Note: 
%   `catchTrial` must include all the columns that `generateTrials` will create
%   based on `blockConfig.trial.generate`. An easy way to find what these are
%   is to run this function without catchTrial or catchIdx.
%
%   If `catchIdx` is not provided, the catch trial will be placed randomly within
%   each block.
%
% The function also adds ITIs to be generated per trial. 
%
% Note: 
%   If ITIs matter (e.g. for fMRI tasks), make sure that you've provided as
%   many of them as necessary for *non-catch* trials. (Catch trials must have
%   their own ITI defined in the column `ITIs`.)
%
% Args:
%   blockConfig: A configuration of the block
%   catchTrial: An single-row table with trial properties for a catch trial
%   catchIdx: (Optional) Catch trial is to be presented as catchIdx'th trial
%   adHocTrials: Any added trials to block
%
% Returns:
%   plannedBlocks: An array of trial tables in block.

0; % to prevent sphinx from thinking that the next comment is more docstring

%% Step 1: Generate all trials for this kind of a block & randomize
levels = blockConfig.trial.generate;
if isempty(blockConfig.trial.importFile)
  allTrials = generateTrials(levels);
else
  allTrials = importTrials(blockConfig.trial.importFile);
end

if exist('adHocTrials', 'var')
  allTrials = [allTrials; adHocTrials];
end

numTrials = height(allTrials);
allTrials = allTrials(randperm(numTrials), :);

%% Step 2: Separate trials into blocks by blockLength
if exist('catchTrial', 'var')
  numCatchTrials = height(catchTrial);
else
  numCatchTrials = 0;
end
blockLengths = getBlockLengths(blockConfig, numTrials, numCatchTrials);
blockNum = length(blockLengths);
plannedBlocks = cell(blockNum, 1); % Pre-allocate

for k = 1:blockNum
  if k == 0
    startIdx = 1;
  else
    startIdx = sum(blockLengths(1:(k - 1))) + 1;
  end
  endIdx = sum(blockLengths(1:k));
  trialTbl = allTrials(startIdx:endIdx, :);

  % Insert ITIs here, before the catch trial, and randomize
  % FIXME: Check for in-phase definition?
  if isfield(blockConfig.trial.generate, 'ITIs')
    ITIs = cutArrayToSize(blockConfig.trial.generate.ITIs(:), blockLengths(k));
    trialTbl.ITIs = ITIs(randperm(length(ITIs)));
  end

  % Insert constant catch trial at catchIdx of each block
  if exist('catchTrial', 'var')
    if exist('catchIdx', 'var')
      trialTbl = injectRowAtIndex(trialTbl, catchTrial, catchIdx, levels);
    else
      trialTbl = injectRowAtIndex(trialTbl, catchTrial, randi(blockLengths(k)), levels);
    end
  end
  plannedBlocks{k} = trialTbl;
end
end

% Helper function
function tbl = injectRowAtIndex(tbl, row, rowIndex, levelConfig)
  % Put a constant `row` at all indices in `rowIndex`.
  %
  % Assumes that the row can be concatenated with the output of `trialTbl`.
  %   If any of the named fields is NaN and levelConfig is provided,
  %   generate a value from that field from levels.
  %
  % Args:
  %   tbl: The original table
  %   row: An area in table where missing information has been filled in
  %   rowIndex: An array of the row indices 
  %   levelConfig:  A configuration level containing trial information
  %
  % Returns:
  %   tbl: A new table with a row at every index.
  if exist('levelConfig', 'var')
    row = generateValuesForMissing(row, levelConfig);
  end

  rowIndex = sort(rowIndex);
  for idx = 1:length(rowIndex)
    tbl_pre = tbl(1:(rowIndex(idx) - 1), :);
    tbl_post = tbl(rowIndex(idx):end, :);
    % FIXME: Use join in case `row` orders the same variables differently
    tbl = [tbl_pre; row; tbl_post];
  end
end

%Helper function
function tbl = generateValuesForMissing(tbl, levelConfig)
  % If any of the columns in `tbl` have NaN in row,
  %   it will insert a random value from corresponding field of `levelConfig`.
  %
  % Args:
  %   tbl: An original table
  %   levelConfig: A configuration level containing trial information 
  %
  % Returns:
  %   tbl: A new table with missing values generated.
  tblCols = tbl.Properties.VariableNames;
  knownLevels = fieldnames(levelConfig);

  for k = 1:numel(tblCols)
    colName = tblCols{k};
    if ~ismember(colName, knownLevels)
      continue
    end
    col = tbl.(colName);
    changable = isnan(col);
    changableIdx = find(changable); % Get non-zero values
    if sum(changable) > 0
      numOptions = length(levelConfig.(colName));
      for l = 1:length(changableIdx)
        tbl(changableIdx(l), k) = {levelConfig.(colName)(randi(numOptions))};
      end
    end
  end
end
