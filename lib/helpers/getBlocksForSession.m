function [ firstIdx, lastIdx ] = getBlocksForSession(DataObject, blocksPerSession)
  % Find the indices for the blocks to begin and end the current session.
  %
  % Args:
  %   DataObject: An object containing block information
  %   blocksPerSession: A variable of the number of blocks run each session 
  %
  % Returns:
  %   2-element tuple containing
  %
  %   - **firstIdx**: The beginning block index.
  %   - **lastIdx**: The ending block index.
  %  
  % NOTE: If all blocks have been done already, `lastIdx` will be an empty
  %   vector. This will prevent any loop of the form k:lastIdx from running, but
  %   you should make sure you don't rely on the numericity of lastIdx in other
  %   ways.
  %
  % Extract relevant values from DataObject
  
  blocksSoFar = DataObject.numFinishedBlocks;
  numBlocks = numel(DataObject.blocks);
  if ~exist('blocksPerSession', 'var')
    try
      blocksPerSession = DataObject.blocks{1}.config.task.blocksPerSession;
    catch
      error('blocksPerSession neither provided nor available from DataObject');
    end
  end

  % First index is easy: it's the block after the latest finished one
  firstIdx = blocksSoFar + 1;

  % Rounding up because we want all blocks to be displayed, even at the cost of
  %   a shorter last session
  numSessions = ceil(numBlocks / blocksPerSession);

  % An array that lists the last block for each session
  lastIndices = (1:numSessions) * blocksPerSession;
  lastIndices(end) = numBlocks;

  % Lsdt index is the first of last-block indices that hasn't been reached yet
  lastIdx = lastIndices(find(firstIdx <= lastIndices, 1, 'first'));
end
