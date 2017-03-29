function c = HLFF_LFConfig(initial_config)
% HLFF_CONFIG_LF Configure low-fat blocks of high-/low-fat food task
  if exist('initial_config', 'var')
    c = initial_config;
  else
    c = configDefaults();
  end

  c.runSetup.blockName = 'Food';
  c.runSetup.conditions.payoffKind = 'Pretzels';

  c.objects.lottery.stakes.fontSize = 24;
  c.objects.reference.fontSize = c.objects.lottery.stakes.fontSize;

  %% Lookup tables
  c.runSetup.lookups.txt = {'No pretzels', '10 pretzels', '15 pretzels', ...
    '20 pretzels', '30 pretzels'};
  c.runSetup.lookups.img = {'nothing.png', 'pretzel1.jpeg', 'pretzel2.jpeg', ...
    'pretzel3.jpeg', 'pretzel4.jpeg'};
  % Fix images to path
  c.runSetup.lookups.img = prependPath(c.runSetup.lookups.img, c.task.imgPath);
end
