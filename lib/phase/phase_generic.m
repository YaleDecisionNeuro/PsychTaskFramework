function [ trialData ] = phase_generic(trialData, blockConfig, phaseConfig)
% Run a "run-of-the-mill" phase

windowPtr = blockConfig.device.windowPtr;

% Draw the background
if isfield(blockConfig.task.fnHandles, 'bgrDrawFn') && ...
    isa(blockConfig.task.fnHandles.bgrDrawFn, 'function_handle')
  blockConfig.task.fnHandles.bgrDrawFn(blockConfig);
end

% Iterate through drawCmds
if isa(phaseConfig.drawCmds, 'function_handle')
  phaseConfig.drawCmds = {phaseConfig.drawCmds};
end
numDrawCmds = numel(phaseConfig.drawCmds);
for k = 1 : numDrawCmds
  phaseConfig.drawCmds{k}(trialData, blockConfig);
end

% Show all drawn objects and retrieve display timestamp
[~, ~, phaseConfig.startTimestamp, ~, ~] = Screen('flip', windowPtr);

% Copy to trialData
timestampName = sprintf('%sStartTS', phaseConfig.name);
trialData.(timestampName) = phaseConfig.startTimestamp;

% Execute phase action(s)
if isa(phaseConfig.action, 'function_handle')
  phaseConfig.action = {phaseConfig.action};
end
numActions = numel(phaseConfig.action);
for k = 1 : numActions
  trialData = phaseConfig.action{k}(trialData, blockConfig, phaseConfig);
end
end
