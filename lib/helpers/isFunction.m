function [ bool ] = isFunction(x)
% Defines whether input object is of specified class.
%
% Args:
%   x: Any matlab object
%
% Returns:
%   bool: A boolean to determine if x is of specified class
  bool = isa(x, 'function_handle');
end
