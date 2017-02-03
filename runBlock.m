function Data = runBlock(Data, blockSettings, trials)
  % Should Data include trials to be run, and trials just the subset?
  % Should blockSettings?
  %
  % What's the best format for `trials`?

  % Assume: order of trials, trial properties, between-subject manipulations
  % (Some can be written here later, or passed as a callback?)

  %% 1. If settings say so, display block title (preblock callback?)
  % Do I know how many-eth block this is?
  %% 2. Iterate through trials
  for i = 1:length(trials)
    drawTrial(Data, i, blockSettings);
  end
  %% 3. Save participant file after block
  %% 4. If settings say so, do something after block
  % ("Ready for next one? Press button...") - this is a natural break
end
