function [ trialTable ] = importTrials(filename)
  if ~exist(filename, 'file')
    % TODO: Maybe this does not have to be a hard failure, but rather allow a
    %   graceful fallback onto on-the-fly generation?
    error('The trial file %s does not exist.', filename)
  else
    trialTable = readtable(filename);
  end
end
