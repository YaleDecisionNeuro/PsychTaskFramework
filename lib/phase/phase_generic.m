function [ trialData ] = phase_generic(trialData, blockSettings, phaseSettings)
% Run a "run-of-the-mill" phase

windowPtr = blockSettings.device.windowPtr;

% Draw the background
if isfield(blockSettings.game, 'bgrDrawFn') && ...
    isa(blockSettings.game.bgrDrawFn, 'function_handle')
  blockSettings.game.bgrDrawFn(blockSettings);
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
timestampName = sprintf('%sStart', phaseSettings.phaseName);
[~, ~, trialData.(timestampName), ~, ~] = Screen('flip', windowPtr);

% Execute phase action(s)
if isa(phaseSettings.action, 'function_handle')
  phaseSettings.action = {phaseSettings.action};
end
numActions = numel(phaseSettings.action);
for k = 1 : numActions
  trialData = phaseSettings.action{k}(trialData, blockSettings);
end
end
