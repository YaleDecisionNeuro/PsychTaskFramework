function drawBgr(blockSettings, callback)
% DRAWBGR Draws default background and sets default drawing properties (e.g.
%   fontName and fontSize). To draw task-specific things, you can supply a
%   callback function that does them. (For instance, you can supply the
%   task-relevant drawRef function.)
%
% NOTE: Unlike other draw functions, it only takes `blockSettings`, not
% `trialSettings`, and does not allow access to or modification of `trialData`.
% (FIXME?)

if ~isfield(blockSettings.device, 'windowPtr')
  error('Device blockSettings contain no designated draw screen');
end

windowPtr = blockSettings.device.windowPtr;
HideCursor(windowPtr);

Screen('FillRect', windowPtr, blockSettings.default.bgrColor);
Screen('TextFont', windowPtr, blockSettings.default.fontName);
Screen('TextSize', windowPtr, blockSettings.default.fontSize);

if exist('callback', 'var') && isa(callback, 'function_handle')
  callback(blockSettings);
end
end
