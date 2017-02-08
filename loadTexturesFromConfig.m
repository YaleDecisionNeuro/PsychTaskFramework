function [ textureMap ] = loadTexturesFromConfig(configStruct, textureMap)
% LOADTEXTURESFROMCONFIG Given a `configStruct`, it will extract all fields
%   named `.img` and return a container mapping valid image filenames to
%   a struct containing their PTB `textureID`, as well as `width` and `height`.
%   If provided with a previously generated `textureMap`, it will avoid
%   redundant loading of previously loaded images.

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
      'width', width, 'height', height);
  end
end

end

function [ filenames ] = extractImagesFromConfig(configStruct)
% EXTRACTIMAGESFROMCONFIG scours `configStruct` for any fields named `img` that
%   contain a character array.  It returns a cell array of all of these fields.

filenames = {};
names = fieldnames(configStruct);
for i = 1:numel(names)
  name = names{i};
  if strcmp(name, 'img')
    if ischar(configStruct.(name))
      filenames = [filenames; configStruct.(name)];
    else
      continue
    end
  elseif isstruct(configStruct.(name))
    filenames = [filenames; extractImagesFromConfig(configStruct.(name))];
  end
end
end
