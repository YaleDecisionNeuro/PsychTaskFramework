function s = UVRA_config(initial_config)
  if ~exist('initial_config', 'var')
    % RA has easily re-used defaults -- see tasks/RA/RA_config for inspiration
    s = RA_config();
  else
    s = initial_config;
  end

  s.device.screenId = 0;
  s.device.taskPath = ['tasks' filesep 'UVRA'];
  s.game.constantTrialDuration = false;

  s.game.optionsPhaseFn = @UVRA_drawTask;
  s.game.referenceDrawFn = @UVRA_drawRef;
  s.game.responsePhaseFn = NaN;
  s.game.feedbackPhaseFn = @UVRA_feedback;

  s.game.durations.choice = Inf;
  s.game.durations.ITIs = 1;

  s.game.block.repeatIndex = 1; % where will the test of stochastic dominance be
  s.game.block.repeatRow = table(4, 0.5, 0, 0, 5, randperm(2, 1), 1, ...
    'VariableNames', {'stakes', 'probs', 'ambigs', 'stakes_loss', 'reference', ...
    'colors', 'ITIs'});
end
