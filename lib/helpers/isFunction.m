function [ bool ] = isFunction(x)
  bool = isa(x, 'function_handle');
end
