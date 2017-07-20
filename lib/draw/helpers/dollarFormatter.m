function [ txt, dims ] = dollarFormatter(value, windowPtr, fontSize)
% When given a numerical value, outputs its correct format
%   in dollars and, if provided `windowPtr`, its width and height on screen.
%
% If `fontSize` is not provided, the width and height will be estimated
%   with currently set font size.
%
% Args:
%   value: The assigned numerical worth
%   windowPtr: A window pointer to specify screen
%   fontSize: The size of the text font
%
% Returns:
%   2-element tuple containing
% 
%   txt: A string of monetary values.
%   dims: The dimensions of the text (txt).

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
