function s = SODM_config_medical(initial_config)
% SODM_CONFIG_MEDICAL Configure medical blocks of the self/other task
  if exist('initial_config', 'var')
    s = initial_config;
  else
    s = config();
  end

  s.game.block.name = 'Medical';

  s.objects.lottery.stakes.fontSize = 24;
  s.objects.reference.fontSize = s.objects.lottery.stakes.fontSize;

  %% Lookup tables
  s.lookups.stakes.txt = {'no effect'; ...
    'slight improvement'; 'moderate improvement'; 'major improvement'; ...
    'recovery'};
  s.lookups.stakes.img = {'no effect.jpg'; 'slight improvement.jpg'; ...
    'moderate improvement.jpg'; 'major improvement.jpg'; 'recovery.jpg'};
  % Fix images to path
  s.lookups.stakes.img = prependPath(s.lookups.stakes.img, s.device.imgPath);
end
