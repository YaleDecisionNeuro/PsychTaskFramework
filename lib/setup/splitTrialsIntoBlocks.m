% TODO: Should this explicitly take `conditions`, like `addGeneratedBlock`?
function [ blocks ] = splitTrialsIntoBlocks(trials, blockConfig) 
  blockLengths = getBlockLengths(blockConfig, height(trials));
  blockNum = length(blockLengths);
  blocks = cell(blockNum, 1); % Pre-allocate

  for k = 1:blockNum
    if k == 0
      startIdx = 1;
    else
      startIdx = sum(blockLengths(1:(k - 1))) + 1;
    end
    endIdx = sum(blockLengths(1:k));
    blockTrials = trials(startIdx:endIdx, :);

    % FIXME: Should a `conditions` arg be expected?
    if exist('conditions', 'var')
      if ~isstruct(conditions)
        warning('Warning: `conditions` is not a structure.');
      end
    else
      if isfield(blockConfig.runSetup, 'conditions')
        conditions = blockConfig.runSetup.conditions;
      else
        conditions = struct.empty;
      end
    end

    % blocks{k} = trialTbl;
    blocks{k} = struct('trials', blockTrials, 'config', blockConfig, ...
      'conditions', conditions, 'data', table(), 'finished', false);
  end
end
