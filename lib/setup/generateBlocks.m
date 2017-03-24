function plannedBlocks = generateBlocks(blockSettings, ...
    catchTrial, catchIdx, adHocTrials)
% GENERATEBLOCKS Returns a cell array of trial tables generated with
%   `generateTrials` from blockSettings.trial.generate, separated into blocks with
%   a fixed number of rows (defined in blockSettings.task.blockLength). If
%   given further arguments, it will also add to the final trial table the
%   table `catchTrial` at per-block indices passed in `catchIdx`. If
%   `adHocTrials` are provided, they are mixed in with the generated trials
%   prior to randomizationand separation into blocks.
%
% NOTE: catchTrial must include all the columns that `generateTrials` will
% create based on `blockSettings.trial.generate`. An easy way to find what these
% are is to run this function without catchTrial or catchIdx.
%
% If catchIdx is not provided, the catch trial will be placed randomly
%   within each block.
%
% The function also adds ITIs to be generated per trial. NOTE: If ITIs matter
% (e.g. for fMRI tasks), make sure that you've provided as many of them as
% necessary for *non-catch* trials. (Catch trials must have their own ITI
% defined in the column `ITIs`.)

%% Step 1: Generate all trials for this kind of a block & randomize
levels = blockSettings.trial.generate;
allTrials = generateTrials(levels);
if exist('adHocTrials', 'var')
  allTrials = [allTrials; adHocTrials];
end
numTrials = height(allTrials);
allTrials = allTrials(randperm(numTrials), :);

%% Step 2: Separate trials into blocks by blockLength
% NOTE: blockLength is assumed to include any catch trials, but those are not
%   assigned yet, which is why they're subtracted.
if exist('catchTrial', 'var')
  minusTrials = height(catchTrial);
else
  minusTrials = 0;
end
blockLen = blockSettings.task.blockLength - minusTrials;

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
  % FIXME: Check for in-phase definition?
  if isfield(blockSettings.trial.generate, 'ITIs')
    ITIs = cutArrayToSize(blockSettings.trial.generate.ITIs(:), blockLen);
    trialTbl.ITIs = ITIs(randperm(length(ITIs)));
  end

  % Insert constant catch trial at catchIdx of each block
  if exist('catchTrial', 'var')
    if exist('catchIdx', 'var')
      trialTbl = injectRowAtIndex(trialTbl, catchTrial, catchIdx, levels);
    else
      trialTbl = injectRowAtIndex(trialTbl, catchTrial, randi(blockLen), levels);
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
