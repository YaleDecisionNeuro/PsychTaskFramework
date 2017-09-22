function [ bool ] = isFunctionOrFunctionArray(x)
% Is the input object is a function handle or a function handle array?
%
% Args:
%    x: Any matlab object
%
% Returns:
%   bool: true if x is function handle or a cell array full of function handles.

  if iscell(x)
    bool = all(cellfun(@(y) isFunction(y), x));
  else
    bool = isFunction(x);
  end
end
