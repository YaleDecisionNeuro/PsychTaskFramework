function [ Data ] = testRA_25()
% testRA_25 Sikuli test: Winning stake has the desired risk
%
% See issue #115. This test picks an asymmetrical lottery in order to
% establish that PTF is displaying the lottery correctly. (If it isn't
% displayed correctly, Sikuli will not make a choice.)

%% Add subfolders we'll be using to path
addpath(genpath('./lib'));
% NOTE: genpath gets the directory and all its subdirectories

%% Setup
config = test_defaults();
config = loadPTB(config);
config = setupPracticeConfig(config);

%% Set up catch trial
trialProperties = struct('stakes', 10, 'probs', 0.25, 'ambigs', [], ...
  'stakes_loss', 0, 'reference', 5, 'colors', 1, 'ITI', 1, 'refSide', 1);
trial = generateTrials(trialProperties);

%% Run it
Data = runGenericTrial(trial, config);

%% Tear down
unloadPTB(config);

%% Test
if Data.choice ~= 1
    error('testRA_25: Sikuli did not see pattern.');
else
    disp('testRA_25: passed.');
end
end
