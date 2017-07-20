function unloadPTB(varargin)
% Closes windows & textures from the passed config(s). Resets Screen config.
%
% closeScreen accepts arbitrarily many config structs.
%
% If the test script did not pass window pointers to the configs, it will
% close all windows.
%
% Args:
%   config1, config2, ...: Any number of configuration objects
if length(varargin) > 0
  windowIds = unique(cell2mat(cellfun(@getWindowId, varargin, ...
    'UniformOutput', false)));
  textureIds = unique(cell2mat(cellfun(@getTextureIds, varargin, ...
    'UniformOutput', false)));
else
  windowIds = [];
  textureIds = [];
end

windowIds = windowIds(~isnan(windowIds));
textureIds = textureIds(~isnan(textureIds));

if isempty(windowIds)
  Screen('CloseAll');
else
  % 1. Close window
  Screen('Close', windowIds);

  % 2. Close all textures
  if ~isempty(textureIds)
    Screen('Close', textureIds);
  end
end

if ismember('refreshConfig', inmem)
  % clear a function whose persistent variable could hold outdated 
  % texture pointers, thus re-initializing the variable
  clear('refreshConfig'); 
end

% 3. Clear Screen config (see PsychDebugWindowConfiguration for details)
clear Screen
end

%% Helper functions to help extract fields and catch errors
function windowId = getWindowId(config)
% Extract window ID fields
%
% Args:
%   config: The program configuration (settings)
%
% Returns:
%   windowId: A defined window.
  try
    windowId = config.device.windowPtr;
  catch
    windowId = [];
  end
end

function textureIds = getTextureIds(config)
% Extract texture ID fields
%
% Args:
%   config: The program configuration (settings)
%
% Returns:
%   textureIds: A defined image texture.
  try
    textureArray = values(config.runSetup.textures);
    textureIds = cellfun(@(x) x.textureId, textureArray, 'UniformOutput', true);
  catch
    textureIds = [];
  end
end
