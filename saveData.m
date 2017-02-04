function [Data] = saveData(Data, folder)
  % TODO: More importantly than this, loadOrCreateDataFile(observer, pwd)!
  % If folder doesn't exist, save in .filename, wherever that might fall
  filename = Data.filename;
  if exist('folder', 'var')
    if ~exist(folder, 'dir')
      mkdir(folder);
    end
    filename = fullfile(folder, filename);
    % Assume that if folder was provided, Data.filename is just filename and not path
  end
  filename = [Data.filename '.mat'];
  disp(['Saving to ', filename]);
  save(filename, Data);
end
