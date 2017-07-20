function [ DataObject ] = preparePractice(DataObject, selectBlockIdx, numTrialsFromBlock)
% Trims DataObject.blocks to selected indices; selects numTrialsFromBlock at random.
%
% Args:
%   DataObject: An object containing data on blocks
%   selectBlockIdx: An array of selected block indices
%   numTrialsFromBlock: The number of trials within a given block
%
% Returns:
%   DataObject: An object containing data on (trimmed) blocks

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

%% Helper function
function [ blockCell ] = selectNTrials(blockCell, n)
% Selects trials within a block.
%
% Args:
%   blockCell: A cell array within a block
%   n: A variable representing the number of selected trials
%
% Returns:
%   blockCell: A cell array (of selected trials) within a block
%
  topBound = height(blockCell.trials);
  randomIdx = randperm(topBound, n);
  blockCell.trials = blockCell.trials(randomIdx, :);
end
