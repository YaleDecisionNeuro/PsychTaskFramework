function s = SODM_config_medical(initial_config)
% SODM_CONFIG_MEDICAL Configure medical blocks of the self/other task
  if exist('initial_config', 'var')
    s = initial_config;
  else
    s = config();
  end

  s.game.block.name = 'Medical';
  s.game.optionsPhaseFn = @SODM_drawTask;
  s.game.referenceDrawFn = @SODM_drawRef;
  s.game.bgrDrawFn = @SODM_drawBgr;
  % FIXME: Is this the best way of showing the context? Why not SODM_drawTask?

  s.game.levels.stakes = 2:5; % Levels are translated via lookup table
  s.game.levels.stakes_loss = 1;
  s.game.levels.reference = 2;

  %% Lookup tables
  s.lookups.stakes.txt = {'no effect'; ...
    'slight improvement'; 'moderate improvement'; 'major improvement'; ...
    'recovery'};
  s.lookups.stakes.img = {'no effect.jpg'; 'slight improvement.jpg'; ...
    'moderate improvement.jpg'; 'major improvement.jpg'; 'recovery.jpg'};
  % Fix images to path
  s.lookups.stakes.img = prependPath(s.lookups.stakes.img, s.device.imgPath);
end
