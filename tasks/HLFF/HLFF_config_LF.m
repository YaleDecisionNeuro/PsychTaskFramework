function s = HLFF_config_LF(initial_config)
% HLFF_CONFIG_LF Configure low-fat blocks of high-/low-fat food task
  if exist('initial_config', 'var')
    s = initial_config;
  else
    s = config();
  end

  s.game.block.name = 'Food';

  s.objects.lottery.stakes.fontSize = 24;
  s.objects.reference.fontSize = s.objects.lottery.stakes.fontSize;

  %% Lookup tables
  s.lookups.stakes.txt = {'10 pretzels', '15 pretzels', ...
    '20 pretzels', '30 pretzels'};
  s.lookups.stakes.img = {'pretzel1.jpeg', 'pretzel2.jpeg', ...
    'pretzel3.jpeg', 'pretzel4.jpeg'};
  % Fix images to path
  s.lookups.stakes.img = prependPath(s.lookups.stakes.img, s.device.imgPath);
end
