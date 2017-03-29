function c = SODM_medicalConfig(initial_config)
% SODM_CONFIG_MEDICAL Configure medical blocks of the self/other task
if exist('initial_config', 'var')
  c = initial_config;
else
  c = configDefaults();
end

c.runSetup.blockName = 'Medical';
c.runSetup.conditions.payoffKind = 'Medical';

c.objects.lottery.stakes.fontSize = 24;
c.objects.reference.fontSize = c.objects.lottery.stakes.fontSize;

%% Lookup tables
c.runSetup.lookups.txt = {'no effect'; ...
  'slight improvement'; 'moderate improvement'; 'major improvement'; ...
  'recovery'};
c.runSetup.lookups.img = {'no effect.jpg'; 'slight improvement.jpg'; ...
  'moderate improvement.jpg'; 'major improvement.jpg'; 'recovery.jpg'};
% Fix images to path
c.runSetup.lookups.img = prependPath(c.runSetup.lookups.img, c.task.imgPath);
end
