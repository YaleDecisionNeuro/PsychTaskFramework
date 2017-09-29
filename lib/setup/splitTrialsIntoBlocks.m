function [ blocks ] = splitTrialsIntoBlocks(trials, blockConfig, conditions) 
% Splits a table of trials into blocks based on provided configuration
%
% Args:
%   trials: a `table` in which each row defines a single trial's properties
%   blockConfig:
%   conditions (optional): a struct with arbitrary fields that describe the
%     condition that blockConfig defines
%   
% Returns:
%   a cell array of ready-to-run blocks
  [ catchTrial, catchIdx ] = getCatchTrial(blockConfig);
  catchTrialCount = height(catchTrial) * length(catchIdx);

  blockLengths = getBlockLengths(blockConfig, height(trials), catchTrialCount);
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

    % Insert a condition
    if exist('conditions', 'var')
      if ~isstruct(conditions)
        warning('Warning: `conditions` is not a structure.');
      end
    else
      if isfield(blockConfig.runSetup, 'conditions')
        % warning('`conditions` was not passed; using blockConfig.runSetup.conditions.');
        conditions = blockConfig.runSetup.conditions;
      else
        warning('`conditions` was neither passed nor defined; making conditions blank.');
        conditions = struct.empty;
      end
    end

    % Insert constant catch trial at catchIdx of each block
    if ~isempty(catchTrial)
      if isnan(catchIdx)
        catchIdx = randi(height(blockTrials));
      end

      try
        blockTrials = injectRowAtIndex(blockTrials, catchTrial, catchIdx);
      catch ME
        warning(['Attempt to add a catch trial raised the %s exception. ', ...
          'The catch trial was not added.'], ME.identifier);
      end
    end

    % blocks{k} = trialTbl;
    blocks{k} = struct('trials', blockTrials, 'config', blockConfig, ...
      'conditions', conditions, 'data', table(), 'finished', false);
  end
end

function [ catchTrial, catchIdx ] = getCatchTrial(blockConfig)
  catchTrial = [];
  catchIdx = NaN;
  if isfield(blockConfig, 'trial') && ...  %isfield(blockConfig.trial, 'catchTrial') || ...
    isfield(blockConfig.trial, 'generate')
    if isfield(blockConfig.trial.generate, 'catchTrial')
      catchTrial = blockConfig.trial.generate.catchTrial;
    end
    if isfield(blockConfig.trial.generate, 'catchIdx')
      catchIdx = blockConfig.trial.generate.catchIdx;
    end
  end
end
