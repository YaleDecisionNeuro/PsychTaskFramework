function [ blockLengths ] = getBlockLengths(blockConfig, numTrials, numCatchTrialsPerBlock)
% Calculates block lengths, given the number of non-catch trials and block config
%
% The block properties that `getBlockLengths` looks at are, in the order of priority:
%
% 1. `numBlocks`
% 2. `blockLength`
% 3. `blocksPerSession`
%
% If `numBlocks` is set, it will determine the generation; consistency warnings
% will occur if the resulting block length isn't equal to `blockLength` [*]. If the
% trials cannot be evenly divided into `numBlocks` blocks and there's a
% remainder of `m` trials, the first `m` blocks will have one extra trial.
%
% If `blockLength` is set but not `numBlocks`, it will result in a strict
% enforcement of block length. Any trials that "overflow" that length will be
% pushed into an additional block.
%
% If neither `numBlocks` nor `blockLength` are existing fields in
% `blockConfig.task`, the script will set `numBlocks` to `blocksPerSession`. If
% none of the properties are set, the function stops with an error.
%
% [*] If `numCatchTrialsPerBlock` is passed, the block length inconsistency warning
% tests instead for equality between `blockLength` set in `blockConfig` and
% derived `blockLength` + `numCatchTrialsPerBlock`.
%
% Args:
%   blockConfig (struct): config struct for the current condition
%   numTrials (integer): the number of non-catch trials to be divided between blocks
%   numCatchTrialsPerBlock (integer): the number of catch trials in each block (optional)
%
% Return:
%   nx1 matrix of block lengths for n blocks **without catch trials**

% Check for the existence of numCatchTrialsPerBlock
if ~exist('numCatchTrialsPerBlock', 'var')
  numCatchTrialsPerBlock = 0;
end

% Extract existing properties and set non-existing to false
if isfield(blockConfig, 'task')
  if isfield(blockConfig.task, 'blockLength')
    configBlockLength = blockConfig.task.blockLength;
  else
    configBlockLength = false;
  end
  if isfield(blockConfig.task, 'blocksPerSession')
    configBlocksPerSession = blockConfig.task.blocksPerSession;
  else
    configBlocksPerSession = false;
  end
  if isfield(blockConfig.task, 'numBlocks')
    configNumBlocks = blockConfig.task.numBlocks;
  else
    configNumBlocks = false;
  end
else
  error('blockConfig does not have the `task` field with block properties');
end

%% Failure mode
% ...or should this just default to a single block with however many trials there are?
if ~configBlockLength && ~configBlocksPerSession && ~configNumBlocks
  error(['blockConfig.task doesn''t set sufficient properties to obtain block lengths. ', ...
    'Set numBlocks, blocksPerSession, and/or blockLength.']);
end

%% Fill in information that's straightforwadly derived
% Number of blocks if both numBlocks and blockLength are absent
if ~configNumBlocks && ~configBlockLength
  if configBlocksPerSession
    configNumBlocks = configBlocksPerSession;
  end
end

% To debug, print the numBlocks and blockLength available to the script:
% fprintf('numBlocks:\t%d\nblockLength:\t%d\n', configNumBlocks, configBlockLength);

% 1. get the block length and block number
% 1a. If there was no way to derive numBlocks, use blockLength
addBlock = false;
if ~configNumBlocks 
  blockLength = configBlockLength - numCatchTrialsPerBlock;
  % subtract numCatchTrialsPerBlock because catch trials are not part of the 
  % trials to be divided up into blocks
  numBlocks = numTrials / blockLength;

  % If there is no way to create even-length blocks, warn, then add an extra
  % block
  lastBlockLength = rem(numTrials, blockLength);
  if lastBlockLength > 0
    addBlock = true;
    warning('PTF:getBlockLengths:extraBlockNeeded', ...
      ['numBlocks = numTrials / blockLength has a non-zero ', ...
      'remainder; adding an extra block with %d trials to accommodate. To ', ...
      'constrain the number of blocks, set blockConfig.task.numBlocks.'], ...
      lastBlockLength);
    numBlocks = floor(numBlocks) + 1;
  end
else % 1b. Use numBlocks to derive blockLength
  numBlocks = configNumBlocks;
  blockLength = numTrials / numBlocks;

  % If there is no way to create even-length blocks, warn, then distribute the
  % remainder across blocks
  leftover = rem(numTrials, numBlocks);
  if leftover > 0
    warning('PTF:getBlockLengths:unevenBlockLengths', ...
      ['blockLength = numTrials / numBlocks has a non-zero remainder;', ...
      ' adding an extra trial to the first %d blocks.'], leftover);
    blockLength = floor(blockLength);
  end

  % Warn about possible block length incosistency
  if configBlockLength && (blockLength + numCatchTrialsPerBlock) ~= configBlockLength
    warning('PTF:getBlockLengths:configBlockLengthInconsistency', ...
      ['Used numBlocks to determine block length, but the generated ', ...
      'block length (%d) isn''t the configured block length (%d). If you ', ...
      'are adding catch trials that make up the difference later, you can ', ...
      'avoid this warning by passing a third argument with the number of ', ...
      'catch trials that will be added to each block.'], ...
      blockLength, configBlockLength);
  end
end

% 2. Create the return matrix
blockLengths = blockLength * ones(numBlocks, 1);

% 3a. If applicable, redistribute the leftovers
if exist('leftover', 'var') && leftover > 0
  blockLengths(1:leftover) = blockLengths(1:leftover) + 1;
end

% 3b. If applicable, adjust the length of the last block
if exist('lastBlockLength', 'var') && addBlock
  blockLengths(end) = lastBlockLength;
end
end
