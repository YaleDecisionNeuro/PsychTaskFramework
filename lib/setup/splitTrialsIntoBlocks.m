function [ blocks ] = splitTrialsIntoBlocks(trials, blockConfig, conditions) 
% Splits a table of trials into blocks based on getBlockLengths(blockConfig)
%
% Args:
%   

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

    % Insert a condition
    if exist('conditions', 'var')
      if ~isstruct(conditions)
        warning('Warning: `conditions` is not a structure.');
      end
    else
      if isfield(blockConfig.runSetup, 'conditions')
        warning('`conditions` was not passed; using blockConfig.runSetup.conditions.');
        conditions = blockConfig.runSetup.conditions;
      else
        warning('`conditions` was neither passed nor defined; making conditions blank.');
        conditions = struct.empty;
      end
    end

    % Insert constant catch trial at catchIdx of each block
    if isfield(blockConfig, 'trial') && ...  %isfield(blockConfig.trial, 'catchTrial') || ...
      isfield(blockConfig.trial, 'generate') && ...
        isfield(blockConfig.trial.generate, 'catchTrial')
      catchTrial = blockConfig.trial.generate.catchTrial;
      try
        if isfield(blockConfig.trial.generate, 'catchIdx')
          catchIdx = blockConfig.trial.generate.catchIdx;
          blockTrials = injectRowAtIndex(blockTrials, catchTrial, catchIdx);
        else
          blockTrials = injectRowAtIndex(blockTrials, catchTrial, randi(height(blockTrials)));
        end
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
