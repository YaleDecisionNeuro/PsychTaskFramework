% Want a function which, given an input argument of the block number,
% returns the condition of that block (medical or monetary) and the block's
% beneficiary (self or other).


function [ uniqueIdx ] = getOneBlockPerCondition(blocks)

% adding paths?
addpath(genpath('./lib'));
addpath(genpath('./tasks/SODM'));

% blocks and numBlocks
numBlocks = length(blocks);

payoffKinds = cell.empty;
beneficiaries = cell.empty;

% iterate through the blocks
for blockIdx = 1:numBlocks
    subsetofblocs = blocks{blockIdx};
    conditions = subsetofblocs.conditions;
    
    payoffKinds{blockIdx} = conditions.payoffKind;
    beneficiaries{blockIdx} = conditions.beneficiary;
end 

% make it into a table
blockTable = table(payoffKinds', beneficiaries'); 

% grab the unique indices to uniqueIdx
[~, uniqueIdx, ~] = unique(blockTable);

end
