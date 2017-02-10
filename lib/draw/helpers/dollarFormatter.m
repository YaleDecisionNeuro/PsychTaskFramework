function [ txt, dims ] = dollarFormatter(value, windowPtr, fontSize)
% DOLLARFORMATTER When given a numerical value, outputs its correct format
%   in dollars and, if provided `windowPtr`, its width and height on screen.
%   (If `fontSize` is not provided, the width and height will be estimated
%   with currently set font size.)

if value < 0
  txt = sprintf('-$%d', -value);
else
  txt = sprintf('$%d', value);
end

if exist('windowPtr', 'var')
  if exist('fontSize', 'var')
    dims = getTextDims(windowPtr, txt, fontSize);
  else
    dims = getTextDims(windowPtr, txt);
  end
end
end
