function arr = cutArrayToSize(arr, n)
% Cuts, or extends, arr so that it has length n.
%
% If `n` is not a direct multiple of the length of `arr`, the first n %%
% length(arr) elements are used.
%
% Args:
%   arr: A cell array
%   n: Length of desired array
%
% Return:
%   arr: A cell array with desired length
%
% Todo: 
%   If this is a character array, make it into a cell array to ensure
%   expected behavior.

if ischar(arr)
  arr = {arr};
end

l = length(arr);
if l > n
  fprintf('Cutting `arr` down from %d to %d...\n', l, n);
  arr = arr(1:n);
elseif l < n
  fprintf('Extending `arr` from %d to %d...\n', l, n);
  arr = repmat(arr(:), floor(n / l), 1);
  remainder = rem(n, l);
  if remainder > 0
    arr = [arr; arr(1 : remainder)];
    warning(['`arr` cannot extend evenly: fill-up of remainder with first'...
      '%n elements'], remainder);
  end
end
end
