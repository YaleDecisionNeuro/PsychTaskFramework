function s = MDM_config_med(initial_config)
% MDM_CONFIG Return settings specific to the medical portion of MDM by
%   modifying the general MDM_config pass as argument.

% Load defaults
s = initial_config;

%% Block properties
s.game.block.name = 'Medical';

%% Font size of payoff text
s.objects.lottery.stakes.fontSize = 24;
s.objects.reference.fontSize = s.objects.lottery.stakes.fontSize;

%% Lookup tables
s.lookups.stakes.txt = {'no effect'; ...
  'slight improvement'; 'moderate improvement'; ...
  'major improvement'; 'recovery'};
s.lookups.stakes.img = {'no effect.jpg'; 'slight improvement.jpg'; ...
  'moderate improvement.jpg'; 'major improvement.jpg'; 'recovery.jpg'};
% Fix images to path
s.lookups.stakes.img = prependPath(s.lookups.stakes.img, s.device.imgPath);
end
