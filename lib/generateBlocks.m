function plannedBlocks = generateBlocks(blockSettings, ...
    includeTrial, includeIndex, adHocTrials)
% GENERATEBLOCKS Returns a cell array of trial tables generated with
%   `generateTrials` from blockSettings.game.levels, separated into blocks with
%   a fixed number of rows (defined in blockSettings.game.block.length). If
%   given further arguments, it will also add to the final trial table the
%   table `includeTrial` at per-block indices passed in `includeIndex`. If
%   `adHocTrials` are provided, they are mixed in with the generated trials
%   prior to randomizationand separation into blocks.
%
% NOTE: IncludeTrial must include all the columns that `generateTrials` will
% create based on `blockSettings.game.levels`. An easy way to find what these
% are is to run this function without includeTrial or includeIndex.
%
% If includeIndex is not provided, the catch trial will be placed randomly
%   within each block.
%
% The function also adds ITIs to be generated per trial. NOTE: If ITIs matter
% (e.g. for fMRI tasks), make sure that you've provided as many of them as
% necessary for *non-catch* trials. (Catch trials must have their own ITI
% defined in the column `ITIs`.)

%% Step 1: Generate all trials for this kind of a block & randomize
levels = blockSettings.game.levels;
allTrials = generateTrials(levels);
if exist('adHocTrials', 'var')
  allTrials = [allTrials; adHocTrials];
end
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

  % Insert ITIs here, before the catch trial. and randomize
  if isfield(blockSettings.game.durations, 'ITIs')
    ITIs = cutArrayToSize(blockSettings.game.durations.ITIs(:), blockLen);
    trialTbl.ITIs = ITIs(randperm(length(ITIs)));
  end

  % Insert constant catch trial at includeIndex of each block
  if exist('includeTrial', 'var')
    if exist('includeIndex', 'var')
      trialTbl = injectRowAtIndex(trialTbl, includeTrial, includeIndex, levels);
    else
      trialTbl = injectRowAtIndex(trialTbl, includeTrial, randi(blockLen), levels);
    end
  end
  plannedBlocks{k} = trialTbl;
end
end

% Helper function
function tbl = injectRowAtIndex(tbl, row, rowIndex, levelSettings)
  % INJECTROWATINDEX Put a constant `row` at all indices in `rowIndex`.
  %   Assumes that the row can be concatenated with the output of `trialTbl`.
  %   If any of the named fields is NaN and levelSettings is provided,
  %   generate a value from that field from levels.
  if exist('levelSettings', 'var')
    row = generateValuesForMissing(row, levelSettings);
  end

  rowIndex = sort(rowIndex);
  for idx = 1:length(rowIndex)
    tbl_pre = tbl(1:(rowIndex(idx) - 1), :);
    tbl_post = tbl(rowIndex(idx):end, :);
    % FIXME: Use join in case `row` orders the same variables differently
    tbl = [tbl_pre; row; tbl_post];
  end
end

function tbl = generateValuesForMissing(tbl, levelSettings)
  % GENERATEVALUESFORMISSING If any of the columns in `tbl` have NaN in row,
  %   it will insert a random value from corresponding field of `levelSettings`.
  tblCols = tbl.Properties.VariableNames;
  knownLevels = fieldnames(levelSettings);

  for k = 1:numel(tblCols)
    colName = tblCols{k};
    if ~ismember(colName, knownLevels)
      continue
    end
    col = tbl.(colName);
    changable = isnan(col);
    changableIdx = find(changable); % Get non-zero values
    if sum(changable) > 0
      numOptions = length(levelSettings.(colName));
      for l = 1:length(changableIdx)
        tbl(changableIdx(l), k) = {levelSettings.(colName)(randi(numOptions))};
      end
    end
  end
end

function arr = cutArrayToSize(arr, n)
  % CUTARRAYTOSIZE Cuts, or extends, arr so that it has length n.
  %
  % NOTE: Duplicates functionality in generateTrials -- refactor?
  l = length(arr);
  if l > n
    warning('Cutting `arr` down from %d to %d...', l, n);
    arr = arr(1:n);
  elseif l < n
    warning('Extending `arr` from %d to %d...', l, n);
    arr = repmat(arr(:), floor(blockLen / numarr), 1);
    remainder = rem(n, l);
    if remainder > 0
      arr = [arr; arr(1 : remainder)];
      warning(['`arr` cannot extend evenly: fill-up of remainder with first'...
        '%n elements'], remainder);
    end
  end
end
