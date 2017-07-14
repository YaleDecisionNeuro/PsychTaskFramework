function s = test_defaults(initial_config)
  if exist('initial_config', 'var')
    s = initial_config;
  else
    s = configDefaults(); % Get defaults from lib/configDefaults
  end
  
  s.debug = false;
  Screen('Preference', 'SkipSyncTests', 1);
  s.device.screenId = 1; % min(1, max(Screen('Screens')));
  
  s.device.breakKeys = {'Space', '5%'};
  s.device.choiceKeys = {'LeftArrow', 'RightArrow'};
  % See lib/configDefaults for other things that s.device can contain

  s.task.fnHandles.trialFn = @runGenericTrial;
  s.task.fnHandles.preBlockFn = NaN;
  % See lib/phase/phaseConfig.m for meaning
  s.trial.phases = { ...
    phaseConfig('showChoice', 10, @phase_showChoice, @action_collectResponse), ...
    phaseConfig('feedback', 0.5, @phase_generic, @action_display, @drawFeedback), ...
    phaseConfig('ITI', 0.5, @phase_ITI, @action_display)};
  s.task.fnHandles.referenceDrawFn = @drawRef;
  s.task.constantBlockDuration = false; % don't need to fit fMRI time blocks
end
