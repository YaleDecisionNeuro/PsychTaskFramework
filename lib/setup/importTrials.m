function [ trialTable ] = importTrials(filename)
% Create a table from trial file
%
% Args:
%   filename: A named file of trial information
%
% Returns:
%   trialTable: A table of the trial information. 

% TODO: Maybe this does not have to be a hard failure, but rather allow a
%   graceful fallback onto on-the-fly generation?
  if ~exist(filename, 'file')
    error('The trial file %s does not exist.', filename)
  else
    trialTable = readtable(filename);
  end
end
