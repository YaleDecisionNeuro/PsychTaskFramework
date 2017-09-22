function [ trialTable ] = importTrials(filename)
% Create a table of trial properties by reading them from a tabular file.
%
% If the provided does not exist, it will raise an error.
%
% Warning:
%   The function does not verify that the file defines the _correct_
%   properties; indeed, it just reads the file and returns its contents.
%
% Args:
%   filename: File name of a tabular file (e.g. in CSV format) with trial
%     properties
%
% Returns:
%   trialTable: A table of the trial information. 
%
% Todo: 
%   Maybe this does not have to be a hard failure, but rather could allow a
%   graceful fallback onto on-the-fly generation?

  if ~exist(filename, 'file')
    error('The trial file %s does not exist.', filename)
  else
    trialTable = readtable(filename);
  end
end
