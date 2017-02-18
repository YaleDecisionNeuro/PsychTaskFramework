function [ Data, blockSettings ] = SODM_preBlock(Data, blockSettings)
  % SODM_PREBLOCK Only display the Myself / Friend part of the block name

  % Check if there are any recorded blocks yet
  if isfield(Data, 'blocks') && isfield(Data.blocks, 'numRecorded')
    blockNum = Data.blocks.numRecorded + 1;
  else
    blockNum = 1;
  end
  blockText = sprintf('Block %d', blockNum);

  % Check if the name of the block is defined
  try
    blockName = sprintf(' (%s)', blockSettings.game.block.name);
  catch
    blockName = '';
  end

  blockText = [blockText, blockName];

  % Display
  % TODO: Factor out the "display text in the center of the screen" logic
  windowPtr = blockSettings.device.windowPtr;
  drawBgr(blockSettings);
  DrawFormattedText(windowPtr, blockText, ...
    'center', 'center', blockSettings.default.fontColor);
  Screen('flip', windowPtr); % NOTE: Necessary to display screen
  waitForBackTick;
end
