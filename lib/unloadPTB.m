function unloadPTB(varargin)
% Closes windows & textures from the passed config(s). Resets Screen settings.
%
% closeScreen accepts arbitrarily many config structs.

windowIds = unique(cell2mat(cellfun(@getWindowId, varargin, 'UniformOutput', false)));
textureIds = unique(cell2mat(cellfun(@getTextureIds, varargin, 'UniformOutput', false)));
% FIXME: This is really ugly; there has to be a more elegant way to do this

% 1. Close window
Screen('Close', windowIds);

% 2. Close all textures
Screen('Close', textureIds);

% 3. Clear Screen settings (see PsychDebugWindowConfiguration for details)
clear Screen
end

%% Helper functions to help extract fields and catch errors
function windowId = getWindowId(config)
  try
    windowId = config.device.windowPtr;
  catch
    windowId = [];
  end
end

function textureIds = getTextureIds(config)
  try
    textureArray = values(config.textures);
    textureIds = cellfun(@(x) x.textureId, textureArray, 'UniformOutput', true);
  catch
    textureIds = [];
  end
end
