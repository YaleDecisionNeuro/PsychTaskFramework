function [ Data, blockConfig ] = preBlock(Data, blockConfig)
  % Display "Block N: (BLOCKNAME)" and wait indefinitely for a break key.
  %
  % Break keys are defined in blockConfig.device.breakKeys.
  %
  % Args:
  %   Data: Information collected (in this case on blocks)
  %   blockConfig: The block settings
  %
  % Returns:
  %   Data: Information collected (unchanged)
  %   blockConfig: The block settings (unchanged)

  0; % to prevent sphinx from thinking that the next comment is more docstring

  % Check if there are any recorded blocks yet
  if isfield(Data, 'blocks') && isfield(Data, 'numFinishedBlocks')
    block_num = Data.numFinishedBlocks + 1;
  else
    block_num = 1;
  end
  block_text = sprintf('Block %d', block_num);

  % Check if the name of the block is defined
  try
    block_name = sprintf(' (%s)', blockConfig.runSetup.blockName);
  catch
    block_name = '';
  end

  block_text = [block_text, block_name];

  % Display
  % TODO: Factor out the "display text in the center of the screen" logic
  windowPtr = blockConfig.device.windowPtr;
  if isfield(blockConfig.task.fnHandles, 'bgrDrawFn') && ...
      isa(blockConfig.task.fnHandles.bgrDrawFn, 'function_handle')
    blockConfig.task.fnHandles.bgrDrawFn(blockConfig);
  end
  DrawFormattedText(windowPtr, block_text, ...
    'center', 'center', blockConfig.graphicDefault.fontColor);
  Screen('flip', windowPtr); % NOTE: Necessary to display screen
  waitForKey(blockConfig.device.breakKeys);
end
