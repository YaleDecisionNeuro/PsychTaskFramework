function s = HLFF_config_monetary(initial_config)
% HLFF_CONFIG_monetary Configure low-fat blocks of high-/low-fat food task
  if exist('initial_config', 'var')
    s = initial_config;
  else
    s = config();
  end

  s.game.block.name = 'Monetary';

  s.game.levels.stakes = [5 8 12 25];
  s.game.levels.stakes_loss = 0;
  s.game.levels.reference = 5;
end
