function [ firstBlockIdx, lastBlockIdx ] = getBlocksForPractice(practiceBlocks)
% Give the practice blocks to run from a trimmed practice-only block set.
%
% Warning:
%   **Deprecated.** Use methods that evaluate lotteries instead.
%
% Note:
%   Assumes that `preparePractice` has been run, removed the blocks that
%   weren't selected, and re-numbered the block span.
%
% Args:
%   practiceBlocks: A set of practice blocks
%
% Returns:
%   2-element tuple containing
%
%   - **firstBlockIdx**: The index of the first block to run
%   - **lastBlockIdx**: The index of the last block to run

firstBlockIdx = 1;
lastBlockIdx = length(practiceBlocks);
end
