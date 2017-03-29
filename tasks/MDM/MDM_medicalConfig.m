function c = MDM_medicalConfig(initial_config)
  % MDM_CONFIG Return settings specific to the medical portion of MDM by
  %   modifying the general MDM_blockDefaults pass as argument.

  % Load defaults
  c = initial_config;

  %% Block properties
  c.runSetup.blockName = 'Medical';
  c.runSetup.conditions.payoffKind = 'Medical';
  c.runSetup.conditions.domain = char.empty;

  %% Font size of payoff text
  c.objects.lottery.stakes.fontSize = 24;
  c.objects.reference.fontSize = c.objects.lottery.stakes.fontSize;

  %% Lookup tables
  c.runSetup.lookups.txt = {'no effect'; ...
    'slight improvement'; 'moderate improvement'; ...
    'major improvement'; 'recovery'};
  c.runSetup.lookups.img = {'no effect.jpg'; 'slight improvement.jpg'; ...
    'moderate improvement.jpg'; 'major improvement.jpg'; 'recovery.jpg'};
  % Fix images to path
  c.runSetup.lookups.img = prependPath(c.runSetup.lookups.img, c.task.imgPath);
end
