function [ firstBlockIdx, lastBlockIdx ] = getBlocksForPractice(practiceBlocks)
% Assumes that `preparePractice` has been run and re-numbers the block span
%
% Args:
%   practiceBlocks: A set of blocks
%
% Returns:
%   firstBlockIdx: The first ordered block in set.
%   lastBlockIdx: The last ordered block in set.

firstBlockIdx = 1;
lastBlockIdx = length(practiceBlocks);
end
