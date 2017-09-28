function [ newOrder ] = rotateBlockOrder(orderMatrix, determinantNumber, determinantFn)
% Deterministically ceunterbalances the order of blocks
%
% Args:
%   orderMatrix: a 1-by-m matrix of values ranging from 1 to n, where m is the
%     number of blocks in the task and n is the number of conditions in the
%     task.  orderMatrix{m} = n means that m-th element of the matrix will be
%     assigned from condition n.
%   determinantNumber: any integer (or, if you're supplying determinantFn, any
%     input that it can process)
%   determinantFn (optional): A function that, given determinantNumber as its
%     only argument, willoutput an integer by which the orderMatrix values
%     should be rotated. By default, it's rem(determinantNumber, n).
%
% Another useful variation on determinantFn is `@(x) ismember(mod(x, 10), [1 2
% 5 7])`, which will flip the order for subjects whose last digit is in the
% array. (Longer, non-anonymous functions are easy as well, especially for
% cases where you have more than two conditions.)
%
% rotateBlockOrder assumes that you'll generally want to keep both contiguity
% of same-condition blocks and the pattern of such contiguities. You might wish
% to look at `circshift` for another way of rotating the order matrix or
% `randperm` for a completely random permutation.

conditionCount = length(unique(orderMatrix));

if exist('determinantFn', 'var')  
  if ~isFunction(determinantFn)
    error(['determinantFn is not a function handle. To provide a function ', ...
      'handle, place the @-sign in front of a function name, e.g. @circshift', ...
      'or @(x) mod(x, 2).'])
  end
else
  determinantFn = @(x) rem(x, conditionCount);
end

newOrder = rem(orderMatrix + determinantFn(determinantNumber), conditionCount) + 1;
end
