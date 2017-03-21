function SODM_drawCondition(blockSettings)
% SODM_drawCondition Draw the designation of a self-rewarding vs.
%   other-rewarding task. This can either be set in
%   blockSettings.game.bgrDrawCallbackFn, or called directly from a draw
%   function.

% FIXME: Extract position into settings
xCoord = blockSettings.objects.condition.position(1);
yCoord = blockSettings.objects.condition.position(2);
DrawFormattedText(blockSettings.device.windowPtr, ...
  SODM_extractBeneficiary(blockSettings), ...
  xCoord, yCoord, ...
  blockSettings.graphicDefault.fontColor);
end
