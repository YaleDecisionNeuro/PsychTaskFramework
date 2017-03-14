function [ trialData ] = runPhase(trialData, blockSettings, phaseSettings)
% Run a phase defined with a phaseConfig construct
trialData = phaseSettings.phaseScript(trialData, blockSettings, phaseSettings);
end
