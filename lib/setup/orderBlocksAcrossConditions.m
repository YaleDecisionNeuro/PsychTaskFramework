function [ blocksArray ] = orderBlocksAcrossConditions(orderMatrix, varargin) 
% Given an order pattern, order blocks for any number of conditions
%
% Args:
%   orderMatrix: a 1-m matrix of values ranging from 1 to n, where m is the
%     number of blocks in the task and n is the number of conditions in the
%     task.  orderMatrix{m} = n means that m-th element of the matrix will be
%     assigned from condition n.  For example, [1 2 2 1] would be an order
%     matrix that places blocks from condition 1 at the start and end of the
%     task, and blocks from condition 2 in the middle.
%   condition1_blocks, condition2_blocks, ...: cell array of blocks, as
%     produced e.g. by `splitTrialsIntoBlocks` (although technically, the
%     function doesn't care about the object class the block is represented
%     with)

% check that at least one condition was received
narginchk(2, Inf);

% check that length of all blocks is equal of the number of blocks
% TODO: fix so that "some multiple" works too
orderCount = length(orderMatrix);
blocksPerConditionCount = cellfun(@(x) length(x), varargin);
blockCount = sum(blocksPerConditionCount);

if blockCount ~= orderCount
  error('orderMatrix doesn''t contain enough elements to account for all passed blocks')
end
 
% check that length of all blocks is some multiple of the number of blocks
if rem(blockCount, orderCount) > 0
  error('Length of orderMatrix does not divide the overall number of blocks evenly.');
end

% check that all conditions are represented in orderMatrix
conditionCount = nargin - 1;
uniqueOrderElts = length(unique(orderMatrix(:)));
if uniqueOrderElts ~= conditionCount
  error('orderMatrix does not represent all passed blocks.')
end

% check that each condition is represented with the right number of blocksArray
orderEltsPerCondition = histcounts(orderMatrix(:));
if blocksPerConditionCount ~= orderEltsPerCondition
  warning('orderMatrix does not have the right number of blocks to represent actual block divisions');
end

%% Actual logic
blocksArray = cell(1, blockCount);
conditionCounts = zeros(1, conditionCount);
for k = 1:length(orderMatrix)
  currentCondition = orderMatrix(k);
  conditionCounts(currentCondition) = conditionCounts(currentCondition) + 1;
  countInCondition = conditionCounts(currentCondition);
  blocksArray{k} = varargin{currentCondition}{countInCondition};
end
end
