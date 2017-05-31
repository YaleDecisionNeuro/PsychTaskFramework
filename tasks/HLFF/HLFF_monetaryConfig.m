function c = HLFF_monetaryConfig(initial_config)
% HLFF_monetaryConfig Configure monetary blocks of high-/low-fat food task
  if exist('initial_config', 'var')
    c = initial_config;
  else
    c = configDefaults();
  end

  c.runSetup.blockName = 'Monetary';

  c.trial.generate.stakes = [5 8 12 25];
  c.trial.generate.stakes_loss = 0;
  c.trial.generate.reference = 5;

  catchVals = struct('stakes', 3, 'probs', NaN, 'ambigs', [], ...
    'stakes_loss', 0, 'reference', 5, 'colors', NaN, 'ITIs', 2);
  c.trial.generate.catchTrial = generateTrials(catchVals);

  c.trial.importFile = [c.task.taskPath filesep 'trials' filesep 'trials_monetary.csv'];
end
