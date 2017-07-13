function [ Data ] = testHLFF_HF_0()
% testHLFF_HF_0 Sikuli test: HLFF "nothing" stake does not cover text

%% Add subfolders we'll be using to path
addpath(genpath('./lib'));
addpath(genpath('./tasks/HLFF'));
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
    error('testHLFF_HF_0: Sikuli did not see pattern.');
else
    disp('testHLFF_HF_0: passed.');
end
end

function [ c ] = localConfig()
  c = test_defaults(HLFF_HFConfig(HLFF_blockDefaults));
    
  %% Lookup tables
%   c.task.imgPath = ['tasks' filesep 'HLFF' filesep 'img'];
%   c.runSetup.lookups.txt = {'No oreos', '4 oreos', '6 oreos', ...
%     '9 oreos', '18 oreos'};
%   c.runSetup.lookups.img = {'nothing.png', 'oreo1.jpeg', 'oreo2.jpeg', ...
%     'oreo3.jpeg', 'oreo4.jpeg'};
%   % Fix images to path
%   c.runSetup.lookups.img = prependPath(c.runSetup.lookups.img, c.task.imgPath);
%   
%   %% Font size of payoff text
%   c.draw.lottery.stakes.fontSize = 24;
%   c.draw.reference.fontSize = c.draw.lottery.stakes.fontSize;
end
