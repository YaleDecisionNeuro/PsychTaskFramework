function SODM_drawCondition(blockConfig)
% Draw the designation of a self-rewarding vs. other-rewarding task. 
% 
% This can either be set in `blockConfig.task.fnHandles.bgrDrawCallbackFn`, or
% called directly from a draw function.
%
% Args:
%   blockConfig: The block settings
% 
% Todo: 
%   Extract position into config
xCoord = blockConfig.draw.condition.position(1);
yCoord = blockConfig.draw.condition.position(2);
DrawFormattedText(blockConfig.device.windowPtr, ...
  SODM_extractBeneficiary(blockConfig), ...
  xCoord, yCoord, ...
  blockConfig.graphicDefault.fontColor);
end
