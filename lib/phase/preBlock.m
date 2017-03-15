function [ Data, blockSettings ] = preBlock(Data, blockSettings)
  % PREBLOCK Display "Block N: (BLOCKNAME)" and wait for press of any of
  %   blockSettings.device.breakKeys.

  % Check if there are any recorded blocks yet
  if isfield(Data, 'blocks') && isfield(Data.blocks, 'numRecorded')
    block_num = Data.blocks.numRecorded + 1;
  else
    block_num = 1;
  end
  block_text = sprintf('Block %d', block_num);

  % Check if the name of the block is defined
  try
    block_name = sprintf(' (%s)', blockSettings.game.block.name);
  catch
    block_name = '';
  end

  block_text = [block_text, block_name];

  % Display
  % TODO: Factor out the "display text in the center of the screen" logic
  windowPtr = blockSettings.device.windowPtr;
  if isfield(blockSettings.game, 'bgrDrawFn') && ...
      isa(blockSettings.game.bgrDrawFn, 'function_handle')
    blockSettings.game.bgrDrawFn(blockSettings);
  end
  DrawFormattedText(windowPtr, block_text, ...
    'center', 'center', blockSettings.default.fontColor);
  Screen('flip', windowPtr); % NOTE: Necessary to display screen
  waitForKey(blockSettings.device.breakKeys);
end
