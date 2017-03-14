function [ bool ] = isFunctionOrFunctionArray(x)
  if iscell(x)
    bool = all(cellfun(@(y) isFunction(y), x));
  else
    bool = isFunction(x);
  end
end
