function [Data] = saveData(Data)
% Saves a subject data file to `Data.filename`. 
%
% Ensures that it stores the struct Data correctly, such that `loadOrCreate` can load it
%   properly.
%
% Args:
%   Data: Participant information.
%
% Returns:
%   Data: Participant information.
%
% (WARNING: The function assumes that the trial-handling functions haven't
% overwritten previous records in Data, and as such, overwrites the file
% without warning.)
%
% TODO: Determine what a file that's being overwritten with different info
%   would look like, and test for that

  % Assume that if folder was provided, Data.filename is just filename and not path
  disp(['Saving to ', Data.filename]);
  save(Data.filename, 'Data');
end
