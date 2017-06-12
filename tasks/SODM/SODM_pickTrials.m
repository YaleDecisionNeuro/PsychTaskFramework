function [trial, config] = SODM_pickTrials(data) 

% from pickAndEvaluateTrial 

% want to pick a trial from each of the 4 types of blocks 
% use getOneBlockPerCondition 
getOneBlockPerCondition(data.blocks) 

% go thru indices, pick trial and config
for index_block = getOneBlockPerCondition(data.blocks)'
    block = data.blocks{index_block};
    trialIdx = randi(height(block.data));
    trial = block.data(trialIdx, :);
    trial.refSide = 1;
    
    config = block.config; 
    
    % want to evaluate showLotteryEvaluation for each of the four trials 
    showLotteryEvaluation(trial, config)

end 

