function s = UVRA_config(initial_config)
  if ~exist('initial_config', 'var')
    % RA has easily re-used defaults -- see tasks/RA/RA_config for inspiration
    s = RA_config();
  else
    s = initial_config;
  end

  s.device.taskPath = ['tasks' filesep 'UVRA'];
  s.game.constantTrialDuration = false;

  s.game.levels.stakes = [5, 8, 12, 17, 25];
  s.game.levels.repeats = 4;
  s.game.block.length = 20;
  s.game.block.numBlocks = 6;

  s.game.optionsPhaseFn = @UVRA_drawTask;
  s.game.referenceDrawFn = @UVRA_drawRef;
  s.game.responsePhaseFn = NaN;
  s.game.feedbackPhaseFn = @UVRA_feedback;

  s.game.durations.choice = Inf;
  s.game.durations.ITIs = 1;
end
