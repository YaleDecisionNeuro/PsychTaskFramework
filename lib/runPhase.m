function [ trialData ] = runPhase(trialData, blockConfig, phaseConfig)
% Run a generic phase defined with a phaseConfig construct.
%
% Args:
%   trialData: Table of trial properties
%   blockConfig: The block settings
%   phaseConfig: The phase settings
%
% Returns:
%   trialData: Table of trial properties, updated with collected data

trialData = phaseConfig.phaseScript(trialData, blockConfig, phaseConfig);
end
