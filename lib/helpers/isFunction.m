function [ bool ] = isFunction(x)
% Is the argument a function handle?
%
% Args:
%   x: Any matlab object
%
% Returns:
%   bool: A boolean to determine if x is of class function handle
  bool = isa(x, 'function_handle');
end
