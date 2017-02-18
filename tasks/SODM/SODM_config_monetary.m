function s = SODM_config_monetary(initial_config)
% SODM_CONFIG_MONETARY Configure monetary blocks of the self/other task
% FIXME: For simplicity, these block settings are only displaying dollar
% values without the images. This should change.
  if exist('initial_config', 'var')
    s = initial_config;
  else
    s = config();
  end

  addpath('./tasks/RA'); % borrowing RA functions for now

  s.game.block.name = 'Monetary';
  s.game.optionsPhaseFn = @SODM_drawMonTask;
  s.game.referenceDrawFn = @RA_drawRef;

  s.game.levels.stakes = [5 8 12 25];
  s.game.levels.stakes_loss = 0;
  s.game.levels.reference = 5;

  s.game.block.length = 12;
end
