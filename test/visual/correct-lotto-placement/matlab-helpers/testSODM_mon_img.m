function [ Data ] = testSODM_mon_img()
% testHLFF0 Sikuli test: SODM monetary stakes are displayed well

%% Add subfolders we'll be using to path
addpath(genpath('./lib'));
addpath(genpath('./tasks/SODM'));
% NOTE: genpath gets the directory and all its subdirectories

%% Setup
config = localConfig();
config = loadPTB(config);
config = setupPracticeConfig(config);
config.runSetup.textures = loadTexturesFromConfig(config);

%% Set up catch trial
trialProperties = struct('stakes', 4, 'probs', [], 'ambigs', 0.5, ...
  'stakes_loss', 1, 'reference', 2, 'colors', 2, 'ITI', 1, 'refSide', 1);
trial = generateTrials(trialProperties);

%% Run it
Data = runGenericTrial(trial, config);

%% Tear down
unloadPTB(config);

%% Test
if Data.choice ~= 1
    error('testSODM_mon_img: Sikuli did not see pattern.');
else
    disp('testSODM_mon_img: passed.');
end
end

function [ c ] = localConfig()
  c = test_defaults(SODM_monetaryConfig(SODM_blockDefaults));
end
