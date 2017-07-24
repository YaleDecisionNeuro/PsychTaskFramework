function c = MDM_medicalConfig(initial_config)
  % Return config specific to the medical portion of MDM by
  %   modifying the general MDM_blockDefaults pass as argument.
  %
  % Args:
  %   initial_config: The initial task settings (medical block)
  %
  % Returns:
  %   c: The initial or default structure architecture for defining the task
%     and its settings (medical block).

  % Load defaults
  c = initial_config;

  %% Block properties
  c.runSetup.blockName = 'Medical';
  c.runSetup.conditions.payoffKind = 'Medical';
  c.runSetup.conditions.domain = char.empty;

  %% Font size of payoff text
  c.draw.lottery.stakes.fontSize = 24;
  c.draw.reference.fontSize = c.draw.lottery.stakes.fontSize;

  %% Lookup tables
  c.runSetup.lookups.txt = {'no effect'; ...
    'slight improvement'; 'moderate improvement'; ...
    'major improvement'; 'recovery'};
  c.runSetup.lookups.img = {'no effect.jpg'; 'slight improvement.jpg'; ...
    'moderate improvement.jpg'; 'major improvement.jpg'; 'recovery.jpg'};
  % Fix images to path
  c.runSetup.lookups.img = prependPath(c.runSetup.lookups.img, c.task.imgPath);
end
