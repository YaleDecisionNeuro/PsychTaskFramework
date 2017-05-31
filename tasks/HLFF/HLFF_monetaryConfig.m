function c = HLFF_monetaryConfig(initial_config)
% HLFF_monetaryConfig Configure monetary blocks of high-/low-fat food task
  if exist('initial_config', 'var')
    c = initial_config;
  else
    c = configDefaults();
  end

  c.runSetup.blockName = 'Monetary';

  c.trial.generate.stakes = [5 8 12 25];
  c.trial.generate.stakes_loss = 0;
  c.trial.generate.reference = 5;
end
