function [ exportTable ] = exportTaskData(taskName, fname)
% Export Exports all participant data in tasks/`taskName`/data.

dataFolder = sprintf(fullfile('tasks', '%s', 'data'), taskName);
dataFiles = dir(fullfile(dataFolder, '*.mat'));

% 1. Load the DataObject from each file
exportTable = table();
for k = 1:length(dataFiles)
  srcName = fullfile(dataFolder, dataFiles(k).name);
  % 2. Feed it to exportParticipant
  DataObject = getfield(load(srcName, 'Data'), 'Data');
  % 3. Concatenate
  exportTable = [exportTable; exportParticipant(DataObject)];
end

% 4. Save
if exist('fname', 'var')
  writetable(exportTable, fname);
end
end
