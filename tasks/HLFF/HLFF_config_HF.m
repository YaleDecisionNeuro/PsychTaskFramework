function s = HLFF_config_HF(initial_config)
% HLFF_CONFIG_HF Configure low-fat blocks of high-/low-fat food task
  if exist('initial_config', 'var')
    s = initial_config;
  else
    s = config();
  end

  s.game.block.name = 'Food';

  s.objects.lottery.stakes.fontSize = 24;
  s.objects.reference.fontSize = s.objects.lottery.stakes.fontSize;

  %% Lookup tables
  s.lookups.stakes.txt = {'4 oreos', '6 oreos', ...
    '9 oreos', '18 oreos'};
  s.lookups.stakes.img = {'oreo1.jpeg', 'oreo2.jpeg', ...
    'oreo3.jpeg', 'oreo4.jpeg'};
  % Fix images to path
  s.lookups.stakes.img = prependPath(s.lookups.stakes.img, s.device.imgPath);
end
