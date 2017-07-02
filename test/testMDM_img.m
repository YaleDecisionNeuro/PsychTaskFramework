function [ Data ] = testMDM_img()
% testMDM_img Sikuli test: Medical decision-making stakes are displayed well

%% Add subfolders we'll be using to path
addpath(genpath('./lib'));
% NOTE: genpath gets the directory and all its subdirectories

%% Setup
config = localConfig();
config = loadPTB(config);
config = setupPracticeConfig(config);
config.runSetup.textures = loadTexturesFromConfig(config);

%% Set up catch trial
trialProperties = struct('stakes', 4, 'probs', [], 'ambigs', 0.5, ...
  'stakes_loss', 1, 'reference', 2, 'colors', 1, 'ITI', 1, 'refSide', 1);
trial = generateTrials(trialProperties);

%% Run it
Data = runGenericTrial(trial, config);

%% Tear down
unloadPTB(config);

%% Test
if Data.choice ~= 1
    error('testMDM_img: Sikuli did not see pattern.');
else
    disp('testMDM_img: passed.');
end
end

function [ c ] = localConfig()
  c = test_defaults;
    
  %% Lookup tables
  c.task.imgPath = ['tasks' filesep 'MDM' filesep 'img'];
  c.runSetup.lookups.txt = {'no effect'; ...
    'slight improvement'; 'moderate improvement'; ...
    'major improvement'; 'recovery'};
  c.runSetup.lookups.img = {'no effect.jpg'; 'slight improvement.jpg'; ...
    'moderate improvement.jpg'; 'major improvement.jpg'; 'recovery.jpg'};
  % Fix images to path
  c.runSetup.lookups.img = prependPath(c.runSetup.lookups.img, c.task.imgPath);
  
  %% Font size of payoff text
  c.draw.lottery.stakes.fontSize = 24;
  c.draw.reference.fontSize = c.draw.lottery.stakes.fontSize;
end
