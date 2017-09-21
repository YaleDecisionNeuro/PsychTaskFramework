function fullpaths = prependPath(filenames, path)
% When given a cell array `filenames`, returns that cell array
% with `path` added before each element of the cell array.
%
% Args:
%   filenames: A cell array of file names
%   path: A string folder on which the filenames are located.
%
% Returns:
%   fullpaths: A cell array with 'path' before each array element.

  if ~strcmp(path(end), '/') && ~strcmp(path(end), '\')
    path = [path filesep];
  end
  fullpaths = cellfun(@(x) [path x], filenames, 'UniformOutput', 0);
end
