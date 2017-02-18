function plannedBlocks = generateBlocks(blockSettings, includeTrial, includeIndex)
% GENERATEBLOCKS Returns a cell array of trial tables generated with
%   `generateTrials` from blockSettings.game.levels, separated into blocks with a
%   fixed number of rows (defined in blockSettings.game.block.length). If given
%   further arguments, it will also add to the final trial table the table
%   `includeTrial` at per-block indices passed in `includeIndex`.
%
% The function also adds ITIs to be generated per trial. NOTE: The number of ITIs
% IncludeTrial must include all the columns that `generateTrials` will create
%   based on `blockSettings.game.levels`. An easy way to find what these are is
%   to run this function without includeTrial or includeIndex.
%
% If includeIndex is not provided, the catch trial will be placed randomly
%   within each block.
%
% TODO: Provide option to not randomly sort all trials right after generation

%% Step 0: Make sure that ITIs are generated per trial, if defined
if isfield(blockSettings.game.durations, 'ITIs')
  ITIs = blockSettings.game.durations.ITIs;
  if ~isempty(ITIs) && sum(~isnan(ITIs)) > 0
    blockSettings.game.levels.ITIs = ITIs;
  end
end

%% Step 1: Generate all trials for this kind of a block & randomize
allTrials = generateTrials(blockSettings.game.levels);
numTrials = height(allTrials);
allTrials = allTrials(randperm(numTrials), :);

%% Step 2: Separate trials into blocks by block.length
% NOTE: Block length is assumed to include any catch trials, but those are not
%   assigned yet, which is why they're subtracted.
if exist('includeTrial', 'var')
  if exist('includeIndex', 'var')
    minusTrials = includeIndex;
  else
    minusTrials = 1;
  end
else
  minusTrials = 0;
end
blockLen = blockSettings.game.block.length - minusTrials;

if rem(numTrials, blockLen) ~= 0
  error('%d trials cannot be divided into even blocks of length %d', ...
    numTrials, blockLen)
end

blockNum = numTrials / blockLen;
plannedBlocks = cell(blockNum, 1); % Pre-allocate

endIndices = (1:blockNum) * blockLen;
for k = 1:length(endIndices)
  startIdx = 1 + (k - 1) * blockLen;
  endIdx = endIndices(k);
  trialTbl = allTrials(startIdx : endIdx, :);
  % Insert constant catch trial at includeIndex of each block
  if exist('includeTrial', 'var')
    if exist('includeIndex', 'var')
      trialTbl = injectRowAtIndex(trialTbl, includeTrial, includeIndex);
    else
      trialTbl = injectRowAtIndex(trialTbl, includeTrial, randi(blockLen));
    end
  end
  plannedBlocks{k} = trialTbl;
end
end

% Helper function
function tbl = injectRowAtIndex(tbl, row, rowIndex)
  % INJECTROWATINDEX Put a constant `row` at all indices in `rowIndex`.
  %   Assumes that the row can be concatenated with the output of `trialTbl`.
  rowIndex = sort(rowIndex);
  for idx = 1:length(rowIndex)
    tbl_pre = tbl(1:(rowIndex(idx) - 1), :);
    tbl_post = tbl(rowIndex(idx):end, :);
    % FIXME: Use join in case `row` orders the same variables differently
    tbl = [tbl_pre; row; tbl_post];
  end
end
