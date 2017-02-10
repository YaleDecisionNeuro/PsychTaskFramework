function [ Data, blockSettings ] = preBlock(Data, blockSettings)
  % PREBLOCK Display "Block N: (Gains/Losses)" and wait for press of 5.
  %
  % TODO: Make it possible to explicitly set a block number.

  % Check if there are any recorded blocks yet
  if isfield(Data, 'recordedBlocks')
    block_num = length(Data.recordedBlocks) + 1;
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
  drawBgr(Data, blockSettings);
  DrawFormattedText(windowPtr, block_text, ...
    'center', 'center', blockSettings.default.fontColor);
  Screen('flip', windowPtr); % NOTE: Necessary to display screen
  waitForBackTick;
end
