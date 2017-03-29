function [ config ] = setupPracticeConfig(config)
% Disable saving and randomize reference side assignment for practice runs
config.device.saveAfterTrial = false;
config.device.saveAfterBlock = false;
config.runSetup.refSide = randi(2);
end
