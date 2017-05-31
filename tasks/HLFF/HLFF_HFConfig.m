function c = HLFF_HFConfig(initial_config)
% HLFF_HFConfig Configure high-fat blocks of high-/low-fat food task
  if exist('initial_config', 'var')
    c = initial_config;
  else
    c = configDefaults();
  end

  c.runSetup.blockName = 'Food';
  c.runSetup.conditions.payoffKind = 'Oreos';

  c.draw.lottery.stakes.fontSize = 24;
  c.draw.reference.fontSize = c.draw.lottery.stakes.fontSize;

  %% Lookup tables
  c.runSetup.lookups.txt = {'No oreos', '4 oreos', '6 oreos', ...
    '9 oreos', '18 oreos'};
  c.runSetup.lookups.img = {'nothing.png', 'oreo1.jpeg', 'oreo2.jpeg', ...
    'oreo3.jpeg', 'oreo4.jpeg'};
  % Fix images to path
  c.runSetup.lookups.img = prependPath(c.runSetup.lookups.img, c.task.imgPath);
end
