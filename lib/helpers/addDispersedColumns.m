function [ tbl ] = addDispersedColumns(tbl, values) 
% For each field in `values`, spread its contents in a new column in `tbl` 
%
% Args:
%   tbl: a `table` with some rows
%   values: a `struct` in which each field is a matrix of values that you'd
%     like distributed evenly across rows of `tbl`
%
% Returns:
%   tbl with additional columns, one for each field in `values`.
%
% Note:
%   To fit each arbitrarily long field in `values` into an arbitrary number of
%   rows, the function uses `cutArrayToSize`. If there's fewer
%   elements than rows, the values will be repeated; if there's more values
%   than rows, the first n terms in each field will be used.

props = structfun(@(x) cutArrayToSize(x, height(tbl)), ...
  values, 'UniformOutput', false);
tbl = [tbl, struct2table(props)];
end
