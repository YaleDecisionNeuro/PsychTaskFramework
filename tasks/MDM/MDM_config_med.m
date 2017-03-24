function s = MDM_config_med(initial_config)
% MDM_CONFIG Return settings specific to the medical portion of MDM by
%   modifying the general MDM_config pass as argument.

% Load defaults
s = initial_config;

%% Block properties
s.runSetup.blockName = 'Medical';

%% Font size of payoff text
s.objects.lottery.stakes.fontSize = 24;
s.objects.reference.fontSize = s.objects.lottery.stakes.fontSize;

%% Lookup tables
s.runSetup.lookups.txt = {'no effect'; ...
  'slight improvement'; 'moderate improvement'; ...
  'major improvement'; 'recovery'};
s.runSetup.lookups.img = {'no effect.jpg'; 'slight improvement.jpg'; ...
  'moderate improvement.jpg'; 'major improvement.jpg'; 'recovery.jpg'};
% Fix images to path
s.runSetup.lookups.img = prependPath(s.runSetup.lookups.img, s.task.imgPath);
end
