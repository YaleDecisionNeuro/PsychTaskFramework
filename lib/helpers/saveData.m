function [Data] = saveData(Data)
% Saves a subject data file to `Data.filename`. 
%
% Ensures that it stores the struct Data correctly, such that `loadOrCreate`
% can load it properly.
%
% Args:
%   Data: Participant information.
%
% Returns:
%   Data: Participant information.
%
% Warning: 
%   The function assumes that the trial-handling functions haven't overwritten
%   previous records in Data, and as such, overwrites the file without
%   warning.
%
% Todo: 
%   Determine what a file that's being overwritten with different info would
%   look like, and test for that


  0; % to prevent sphinx from thinking that the next comment is more docstring

  % Assume that if folder was provided, Data.filename is just filename and not path
  disp(['Saving to ', Data.filename]);
  save(Data.filename, 'Data');
end
