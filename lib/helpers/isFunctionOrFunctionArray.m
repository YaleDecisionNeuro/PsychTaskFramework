function [ bool ] = isFunctionOrFunctionArray(x)
% Determines whether input object is a cell array.
%
% Args:
%    x: Any matlab object
%
% Returns:
%   bool: A boolean defining the cell array or the class of the object.

  if iscell(x)
    bool = all(cellfun(@(y) isFunction(y), x));
  else
    bool = isFunction(x);
  end
end
