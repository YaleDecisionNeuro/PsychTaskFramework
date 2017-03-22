function drawBgr(blockSettings, callback)
% DRAWBGR Draws default background and sets default drawing properties (e.g.
%   fontName and fontSize). To draw task-specific things, you can supply a
%   callback function that does them. (For instance, you can supply the
%   task-relevant drawRef function.)
%
% NOTE: Unlike other draw functions, it only takes `blockSettings`, not
% `trialData`, and does not allow access to or modification of `trialData`.
% (FIXME?)

if ~isfield(blockSettings.device, 'windowPtr')
  error('Device blockSettings contain no designated draw screen');
end

windowPtr = blockSettings.device.windowPtr;
HideCursor(windowPtr);

Screen('FillRect', windowPtr, blockSettings.graphicDefault.bgrColor);
Screen('TextFont', windowPtr, blockSettings.graphicDefault.fontName);
Screen('TextSize', windowPtr, blockSettings.graphicDefault.fontSize);

if isfield(blockSettings.task.fnHandles, 'bgrDrawCallbackFn') && ...
    isFunction(blockSettings.task.fnHandles.bgrDrawCallbackFn)
  blockSettings.task.fnHandles.bgrDrawCallbackFn(blockSettings);
end
if exist('callback', 'var') && isFunction(callback)
  callback(blockSettings);
end
end
