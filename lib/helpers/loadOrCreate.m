function [ Data, existed ] = loadOrCreate(subjectId, fname)
% Load a subject data file. If it does not exist, create it.
%
% Args:
%   subjectID: A participant ID
%   fname: A filename
%
% Returns:
%   2-element tuple containing
%
%   - **Data**: Participant information.
%   - **existed**: A recorded file of participant information.
%
% Note: 
%   Currently assumes that subject data is stored in a struct called Data,
%   and that the folders in the path to `fname` all exist.

[path, ~, ~] = fileparts(fname);
if ~exist(path, 'dir')
  mkdir(path);
end

existed = exist(fname, 'file');
if existed
  temp = load(fname, 'Data');
  Data = temp.Data;
  Data.lastAccess = datestr(now, 'yyyymmddTHHMMSS');
else
  Data.subjectId = subjectId;
  Data.blocks = cell.empty;
  Data.numFinishedBlocks = 0;

  if ~isnan(subjectId) % actual subject
    Data.created = datestr(now, 'yyyymmddTHHMMSS');
    Data.lastAccess = datestr(now, 'yyyymmddTHHMMSS');
    Data.filename = fname;
    save(fname, 'Data');
  end
end
end
