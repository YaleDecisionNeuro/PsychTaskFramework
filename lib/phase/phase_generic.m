function [ trialData ] = phase_generic(trialData, blockSettings, phaseSettings)
% Run a "run-of-the-mill" phase

windowPtr = blockSettings.device.windowPtr;

% Draw the background
if isfield(blockSettings.task.fnHandles, 'bgrDrawFn') && ...
    isa(blockSettings.task.fnHandles.bgrDrawFn, 'function_handle')
  blockSettings.task.fnHandles.bgrDrawFn(blockSettings);
end

% Iterate through drawCmds
if isa(phaseSettings.drawCmds, 'function_handle')
  phaseSettings.drawCmds = {phaseSettings.drawCmds};
end
numDrawCmds = numel(phaseSettings.drawCmds);
for k = 1 : numDrawCmds
  phaseSettings.drawCmds{k}(trialData, blockSettings);
end

% Show all drawn objects and retrieve display timestamp
[~, ~, phaseSettings.startTimestamp, ~, ~] = Screen('flip', windowPtr);

% Copy to trialData
timestampName = sprintf('%sStartTS', phaseSettings.name);
trialData.(timestampName) = phaseSettings.startTimestamp;

% Execute phase action(s)
if isa(phaseSettings.action, 'function_handle')
  phaseSettings.action = {phaseSettings.action};
end
numActions = numel(phaseSettings.action);
for k = 1 : numActions
  trialData = phaseSettings.action{k}(trialData, blockSettings, phaseSettings);
end
end
