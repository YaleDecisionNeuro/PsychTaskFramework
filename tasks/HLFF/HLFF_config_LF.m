function s = HLFF_config_LF(initial_config)
% HLFF_CONFIG_LF Configure low-fat blocks of high-/low-fat food task
  if exist('initial_config', 'var')
    s = initial_config;
  else
    s = config();
  end

  s.runSetup.blockName = 'Food';

  s.objects.lottery.stakes.fontSize = 24;
  s.objects.reference.fontSize = s.objects.lottery.stakes.fontSize;

  %% Lookup tables
  s.runSetup.lookups.txt = {'No pretzels', '10 pretzels', '15 pretzels', ...
    '20 pretzels', '30 pretzels'};
  s.runSetup.lookups.img = {'nothing.png', 'pretzel1.jpeg', 'pretzel2.jpeg', ...
    'pretzel3.jpeg', 'pretzel4.jpeg'};
  % Fix images to path
  s.runSetup.lookups.img = prependPath(s.runSetup.lookups.img, s.task.imgPath);
end
