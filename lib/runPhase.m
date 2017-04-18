function [ trialData ] = runPhase(trialData, blockConfig, phaseConfig)
% Run a phase defined with a phaseConfig construct
trialData = phaseConfig.phaseScript(trialData, blockConfig, phaseConfig);
end
