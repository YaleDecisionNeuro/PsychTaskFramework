function fullpaths = prependPath(filenames, path)
  % PREPENDPATH When given a cell array `filenames`, returns that cell array
  %   with `path` added before each element of the cell array.
  if ~strcmp(path(end), '/') && ~strcmp(path(end), '\')
    path = [path filesep];
  end
  fullpaths = cellfun(@(x) [path x], filenames, 'UniformOutput', 0);
end
