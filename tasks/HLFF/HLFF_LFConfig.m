function c = HLFF_LFConfig(initial_config)
% Configure low-fat blocks of high-/low-fat food task.
%
% Args:
%   initial_config: The initial task settings (LF block)
%
% Returns:
%   c: The initial or default structure architecture for defining the task
%     and its settings (LF block).

  if exist('initial_config', 'var')
    c = initial_config;
  else
    c = configDefaults();
  end

  c.runSetup.blockName = 'Food';
  c.runSetup.conditions.payoffKind = 'Pretzels';

  c.trial.importFile = [c.task.taskPath filesep 'trials' filesep 'trials_LF.csv'];

  c.draw.lottery.stakes.fontSize = 24;
  c.draw.reference.fontSize = c.draw.lottery.stakes.fontSize;

  %% Lookup tables
  c.runSetup.lookups.txt = {'No pretzels', '10 pretzels', '15 pretzels', ...
    '20 pretzels', '30 pretzels'};
  c.runSetup.lookups.img = {'nothing.png', 'pretzel1.jpeg', 'pretzel2.jpeg', ...
    'pretzel3.jpeg', 'pretzel4.jpeg'};
  % Fix images to path
  c.runSetup.lookups.img = prependPath(c.runSetup.lookups.img, c.task.imgPath);
end
