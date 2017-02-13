function s = MDM_config()
% MDM_CONFIG Return general block settings for the medical decision-making
%   task by modifying the default ones from `config`.
Factor out phase scripts

% Load defaults
s = config();

%% Machine settings
s.device.screenId = 1; % 0 for current screen, 1 for a second screen

%% Features of objects that your task displays
% Inheriting all objects from `config`

%% Non-display settings for the game
% (Maximum) durations of the various stages, in seconds
s.game.durations.choice = 6;
s.game.durations.response = 3.5;
s.game.durations.feedback = 0.5;
s.game.durations.ITIs = 2;
% All ITI durations will be 2 -- see default for variable length ITIs

%% Block properties
s.game.name = 'MDM';
s.game.block.name = 'Medical';
s.game.optionsPhaseFn = @MDM_drawTask;
s.game.referenceDrawFn = @MDM_drawRef;
s.game.preBlockFn = @preBlock;

% Useful for generation purposes
s.game.block.length = 10;
% s.game.block.repeatIndex = NaN;
% s.game.block.repeatTrial = NaN;

%% Available trial values
s.game.levels.stakes = 1:5; % Levels are translated via lookup table
s.game.levels.probs = [.25 .5 .75];
s.game.levels.ambigs = [.24 .5 .74];
s.game.levels.stakes_loss = 1;
s.game.levels.reference = 2;
s.game.levels.colors = [1 2];
s.game.levels.repeats = 1;

%% Lookup tables
s.lookups.stakes.txt = {'no effect'; ...
  'slight improvement'; 'moderate improvement'; 'major improvement'; ...
  'recovery'};
s.lookups.stakes.img = {'symbol/no effect.jpg'; ...
  'symbol/slight improvement.jpg'; 'symbol/moderate improvement.jpg'; ...
  'symbol/major improvement.jpg'; 'symbol/recovery.jpg'};
end
