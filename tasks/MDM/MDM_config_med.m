function s = MDM_config_med(initial_config)
% MDM_CONFIG Return settings specific to the medical portion of MDM by
%   modifying the general MDM_config pass as argument.

% Load defaults
s = initial_config;

%% Block properties
s.game.block.name = 'Medical';
s.game.optionsPhaseFn = @MDM_drawTask;
s.game.referenceDrawFn = @MDM_drawRef;
s.game.block.length = 15;

% Useful for generation purposes
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
s.lookups.stakes.img = {'no effect.jpg'; 'slight improvement.jpg'; ...
  'moderate improvement.jpg'; 'major improvement.jpg'; 'recovery.jpg'};
% Fix images to path
s.lookups.stakes.img = prependPath(s.lookups.stakes.img, s.device.imgPath);
end
