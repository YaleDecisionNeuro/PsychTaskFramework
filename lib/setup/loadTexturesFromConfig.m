function [ textureMap ] = loadTexturesFromConfig(configStruct, textureMap)
% Create a texture map of images and image information.
%
% Given a `configStruct`, it will extract file paths
%   named `.img` and return a container mapping valid image filenames to
%   a struct containing PTB's `.textureId` and their dimentsions in `.dims`.
%   If provided with a previously generated `textureMap`, it will avoid
%   redundant loading of previously loaded images.
%
% Args:
%   configStruct: A configuration structure containing named images
%   textureMap: A data structure of images and image information mapped to a key.
%
% Returns:
%   textureMap: A data structure of images and image information mapped to a key.

if ~exist('textureMap', 'var')
  textureMap = containers.Map;
end

imgFiles = extractImagesFromConfig(configStruct);

for i = 1:length(imgFiles)
  loaded = keys(textureMap);
  fname = imgFiles{i};
  if sum(strcmp(fname, loaded)) > 0
    continue % already loaded
  else
    % 1. Load image (abort if impossible)
    try
      img = imread(fname);
    catch
      error('Image at "%s" does not exist; aborting preload.', fname);
      % NOTE: This could be a warning, but error should prevent a nasty
      %   surprise later.
    end

    % 2. Get width + height
    [width, height, ~] = size(img);

    % 3. Make into texture and note texture ID
    textureId = Screen('MakeTexture', configStruct.device.windowPtr, img);

    % 4. Write into textureMap
    textureMap(fname) = struct('textureId', textureId, ...
      'dims', [width height]);
  end
end

end

function [ filenames ] = extractImagesFromConfig(configStruct)
% Creates files of existing images. 
%
% Scours `configStruct` for any fields named `img` that
%   contain a character array.  It returns a cell array of all of these fields.
%
% Args:
%   configStruct: A configuration structure containing named images
% 
% Returns:
%   filenames: A defined file.

filenames = {};
names = fieldnames(configStruct);
for i = 1:numel(names)
  name = names{i};
  if strcmp(name, 'img')
    temp = configStruct.(name);
    if ischar(temp)
      % string to save
      filenames = [filenames; temp];
    elseif iscell(temp)
      % cell array of possible filenames
      for j = 1:length(temp)
        if ischar(temp{j})
          filenames = [filenames; temp{j}];
        end
      end
    else
      continue
    end
  elseif isstruct(configStruct.(name))
    filenames = [filenames; extractImagesFromConfig(configStruct.(name))];
  end
end
end
