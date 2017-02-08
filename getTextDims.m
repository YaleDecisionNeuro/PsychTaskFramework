function [ dims ] = getTextDims(windowPtr, txt, fontSize)
% GETTEXTDIMS For window at `windowPtr`, get dimensions of `txt`. This will
%   be at current font size or, if provided, at `fontSize`.
%
% Adapted from Ruonan Jia's initial implementation in the MDM task.

if exist('fontSize', 'var')
  oldFontSize = Screen('TextSize', windowPtr);
  Screen('TextSize', windowPtr, fontSize);
end

[normBounds, offsetBounds] = Screen('TextBounds', windowPtr, txt);
% TODO: Would offsetBounds be better for any purpose?
dims = normBounds(3:4);

if exist('oldFontSize', 'var')
  Screen('TextSize', windowPtr, oldFontSize);
end
end
