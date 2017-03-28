function [ DataObject ] = preparePractice(DataObject, selectBlockIdx, numTrialsFromBlock)
% Trims DataObject.blocks to selected indices; selects numTrialsFromBlock at random.
numBlocks = numel(DataObject.blocks);
if isempty(intersect(selectBlockIdx, 1:numBlocks))
  error('Out of bounds: you requested a block that has not been generated.');
end

% Subset the DataObject
DataObject.blocks = DataObject.blocks(selectBlockIdx);

% Subset the trials in each block
DataObject.blocks = cellfun(@(x) selectNTrials(x, numTrialsFromBlock), ...
  DataObject.blocks, 'UniformOutput', false);
end

function [ blockCell ] = selectNTrials(blockCell, n)
  topBound = height(blockCell.trials);
  randomIdx = randperm(topBound, n);
  blockCell.trials = blockCell.trials(randomIdx, :);
end
