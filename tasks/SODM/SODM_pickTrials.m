function [trial, config] = SODM_pickTrials(data) 

% ugly hack? 
config = data.blocks{end}.config;

% Show that trials have ended and lottery evaluations are about to begin 
 msg = 'Trials have ended. Please wait for the experimenter.'; 

 windowPtr = config.device.windowPtr;
 txtDims = getTextDims(config.device.windowPtr, msg);
 xDim = config.device.screenDims(3)/2 - txtDims(1)/2;
 yDim = config.device.screenDims(4) - 20;

 DrawFormattedText(config.device.windowPtr, msg, xDim, yDim, [200 200 200]);
 Screen('flip', windowPtr);
 
 waitForKey(config.device.breakKeys); %experimenter presses 5 to continue 

% go thru indices, pick trial and config
for index_block = getOneBlockPerCondition(data.blocks)'
    block = data.blocks{index_block};
    trialIdx = randi(height(block.data));
    trial = block.data(trialIdx, :);
    trial.refSide = 1;
    
    config = block.config; 
    
    % want to evaluate showLotteryEvaluation for each of the four trials 
    showTrialEvaluation(trial, config)
    
    % After receiving prompt, begin (next) lottery: 
     waitForKey(config.device.breakKeys);

end 

