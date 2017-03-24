function [ exportTable ] = exportTaskData(taskName, fname)
% Export Exports all subject data in tasks/`taskName`/data.

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
