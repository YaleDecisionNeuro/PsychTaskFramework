function [ config ] = setupPracticeConfig(config)
% Disable saving and randomize reference side assignment for practice runs
%
% Args:
%   config: A configuration of practice runs
%
% Returns:
%   config: An updated configuration of practice runs
config.device.saveAfterTrial = false;
config.device.saveAfterBlock = false;
config.runSetup.refSide = randi(2);
end
