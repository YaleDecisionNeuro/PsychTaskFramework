function [ Data, existed ] = loadOrCreate(participantId, fname)
% LOADORCREATE Load a participant data file. If it does not exist, create it.
% (Currently assumes that participant data is stored in a struct called Data.)

% FIXME: Currently expects that the folder in which to save data exists
existed = exist(fname, 'file');
if existed
  temp = load(fname, 'Data');
  Data = temp.Data;
else
  Data.observer = participantId;
  Data.filename = fname;
  save(fname, 'Data');
end
end
