function [ trialData ] = runPhase(trialData, blockConfig, phaseConfig)
% Run a phase defined with a phaseConfig construct.
%
% Args:
%   trialData: Information gathered from a trial
%   blockConfig: The block settings
%   phaseConfig: The phase settings
%
% Returns:
%   trialData: Information gathered from a trial.

trialData = phaseConfig.phaseScript(trialData, blockConfig, phaseConfig);
end
