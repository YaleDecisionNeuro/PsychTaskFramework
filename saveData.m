function [Data] = saveData(Data)
% SAVEDATA Saves a participant data file to `Data.filename`. Ensures that it
%   stores the struct Data correctly, such that `loadOrCreate` can load it
%   properly.
%
% (WARNING: The function assumes that the trial-handling functions haven't
% overwritten previous records in Data, and as such, overwrites the file
% without warning.)

  % Assume that if folder was provided, Data.filename is just filename and not path
  disp(['Saving to ', Data.filename]);
  save(Data.filename, 'Data');
end
