function Data = runBlock(Data, blockSettings)
  % RUNBLOCK Scaffolds multiple trial calls of the same kind and saves the file
  %   after al of them have run.
  %
  % The main thing `runBlock` needs from blockSettings is for `.game.trialFn`
  % to be a function handle to which it can pass Data, trial #, and blockSettings.
  %
  % If `blockSettings.game` includes fields `preBlockFn` and/or `postBlockFn`,
  % it will assume they are callable functions and call them with `Data` and
  % `blockSettings` as arguments. (This means they can display block beginning
  % / end and wait for keypress, or check if requisite values exist and fail
  % gracefully, or any number of other things.)
  %
  % If `Data.filename` does not exist, it will not know how to save the trial
  % choices (and will issue a warning).

  %% 1. If settings say so, display block title (preblock callback?)
  % Do I know how many-eth block this is?
  if isfield(blockSettings.game, 'preBlockFn')
    blockSettings.game.preBlockFn(Data, blockSettings);
  end

  %% 2. Iterate through trials
  numTrials = blockSettings.game.numTrials; % FIXME: This should be clear from property table
  % FIXME: Should be passed as a goddamn table
  drawTrial = blockSettings.game.trialFn;

  if ~isa(drawTrial, 'function_handle')
    error(['Function to draw trials not supplied! Make sure that you''ve set' ...
      ' settings.game.trialFn = @your_function_to_draw_trials']);
  end

  for i = 1:numTrials
    % FIXME: Should only receive per-trial data from drawTrial and collate them
    Data = drawTrial(Data, i, blockSettings);
  end
  %% 3. Save participant file after block
  save(Data.filename, 'Data');

  %% 4. If settings say so, do something after block
  if isfield(blockSettings.game, 'postBlockFn')
    blockSettings.game.postBlockFn(Data, blockSettings);
  end
  % ("Ready for next one? Press button...") - this is a natural break
end
