function [ Summary ] = experimentSummary(Data, bagMap)
% EXPERIMENTSUMMARY Iterates over Data.blocks.recorded and stores information
%   necessary for lottery realization in a block-by-trial struct. If `bagMap`
%   is supplied, it will use it instead of the default lookup map.
%
% NOTE: You might want to load the bagMap from a CSV/XLS file.
%
% FIXME: Currently, this is just snippets of logic -- it doesn't actually work!

if ~exist('bagMap', 'var')
  probs = [.5 .5 .5 .5 .25 .25 .75 .75]';
  ambigs = [0 .24 .5 .74 0 0 0 0]';
  colors = [NaN NaN NaN NaN 1 2 1 2]';
  bagNumber = [4 10 11 12 3 5 3 5]';
  bagMap = table(probs, ambigs, colors, bagNumber);
end

% Loop through blocks
blockFld = DataObject.blocks;
numBlocks = blockFld.numRecorded;
for k = 1:numBlocks
  blockInfo = blockFld.recorded{k};
  blockConfig = blockInfo.settings;
  % TODO: Extract color key information from blockFld.recorded{k}.
  blockTrials = blockInfo.records;

  for l = 1:height(blockTrials)
    % Save info to a, p, c
    mask = bagMap.probs == p & bagMap.ambigs == a;
    if sum(mask) > 1
      mask = bagMap.probs == p & bagMap.ambigs == a & bagMap.colors == c;
    end
    bag = bagMap.bagNumber(mask);
    % Save info to Summary
  end
end

end
