function [ exportTable ] = exportTaskData(taskName, fname)
% Exports all subject data in tasks/`taskName`/data.
%
% Note:
%   The function merely concatenates the sequential outputs of exportSubject.
%
% Args:
%   taskName: Name of the task to export. Assumed to be folder name.
%   fname: Optional file name in which to save the results table.
% 
% Returns:
%   exportTable: A table of all participant data collected in the task.

dataFolder = fullfile('tasks', taskName, 'data');
dataFiles = dir(fullfile(dataFolder, '*.mat'));

% 1. Load the DataObject from each file
exportTable = table();
for k = 1:length(dataFiles)
  srcName = fullfile(dataFolder, dataFiles(k).name);
  % 2. Feed it to exportSubject
  DataObject = getfield(load(srcName, 'Data'), 'Data');
  % 3. Concatenate
  exportTable = [exportTable; exportSubject(DataObject)];
end

% 4. Save
if exist('fname', 'var')
  writetable(exportTable, fname);
end
end
