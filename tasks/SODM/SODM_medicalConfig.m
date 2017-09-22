function c = SODM_medicalConfig(initial_config)
% Configure medical blocks of the self/other task.
%
% Args:
%   initial_config: Task config struct to modify
%
% Returns:
%   Config struct specific to the medical conditions of the self/other task

if exist('initial_config', 'var')
  c = initial_config;
else
  c = configDefaults();
end

c.runSetup.blockName = 'Medical';
c.runSetup.conditions.payoffKind = 'Medical';

c.draw.lottery.stakes.fontSize = 24;
c.draw.reference.fontSize = c.draw.lottery.stakes.fontSize;

%% Lookup tables
c.runSetup.lookups.txt = {'no effect'; ...
  'slight improvement'; 'moderate improvement'; 'major improvement'; ...
  'recovery'};
c.runSetup.lookups.img = {'no effect.jpg'; 'slight improvement.jpg'; ...
  'moderate improvement.jpg'; 'major improvement.jpg'; 'recovery.jpg'};
% Fix images to path
c.runSetup.lookups.img = prependPath(c.runSetup.lookups.img, c.task.imgPath);
end
