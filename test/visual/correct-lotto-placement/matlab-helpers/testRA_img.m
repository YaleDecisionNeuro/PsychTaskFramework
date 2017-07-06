function [ Data ] = testRA_img()
% testRA_25 Sikuli test: Visualization of monetary symbols

%% Add subfolders we'll be using to path
addpath(genpath('./lib'));
% NOTE: genpath gets the directory and all its subdirectories

%% Setup
config = localConfig();
config = loadPTB(config);
config = setupPracticeConfig(config);
config.runSetup.textures = loadTexturesFromConfig(config);

%% Set up catch trial
trialProperties = struct('stakes', 4, 'probs', [], 'ambigs', 0.24, ...
  'stakes_loss', 1, 'reference', 2, 'colors', 1, 'ITI', 1, 'refSide', 1);
trial = generateTrials(trialProperties);

%% Run it
Data = runGenericTrial(trial, config);

%% Tear down
unloadPTB(config);

%% Test
if Data.choice ~= 1
    error('testRA_img: Sikuli did not see pattern.');
else
    disp('testRA_img: passed.');
end
end

function [ c ] = localConfig()
  c = test_defaults;
    
  %% Lookup tables
  c.task.imgPath = ['tasks' filesep 'MDM' filesep 'img'];
  c.runSetup.lookups.txt = {'$0'; '$5'; '$8'; '$12'; '$25'};
  c.runSetup.lookups.img = {'0.jpg'; '5.jpg'; '8.jpg'; '12.jpg'; '25.jpg'};
  % Fix images to path
  c.runSetup.lookups.img = prependPath(c.runSetup.lookups.img, c.task.imgPath);
end
