function drawBgr(blockConfig, callback)
% Draws default background and sets default drawing properties (e.g.
%   fontName and fontSize). 
%
% To draw task-specific things, you can supply a
%   callback function that does them. For instance, you can supply the
%   task-relevant drawRef function.
%
% Args:
%   blockConfig: The block settings
%   callback: A retrieval of previous (default) information 
%
% NOTE: Unlike other draw functions, it only takes `blockConfig`, not
%   `trialData`, and does not allow access to or modification of `trialData`.
%   (FIXME?)

if ~isfield(blockConfig.device, 'windowPtr')
  error('Device blockConfig contain no designated draw screen');
end

windowPtr = blockConfig.device.windowPtr;
HideCursor(windowPtr);

Screen('FillRect', windowPtr, blockConfig.graphicDefault.bgrColor);
Screen('TextFont', windowPtr, blockConfig.graphicDefault.fontName);
Screen('TextSize', windowPtr, blockConfig.graphicDefault.fontSize);

if isfield(blockConfig.task.fnHandles, 'bgrDrawCallbackFn') && ...
    isFunction(blockConfig.task.fnHandles.bgrDrawCallbackFn)
  blockConfig.task.fnHandles.bgrDrawCallbackFn(blockConfig);
end
if exist('callback', 'var') && isFunction(callback)
  callback(blockConfig);
end
end
