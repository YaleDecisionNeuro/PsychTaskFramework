function [ blockConfig ] = refreshConfig( blockConfig )
% Checks that window pointer and texture pointers in blockConfig are valid
%
% Note: refreshConfig holds all previously generated textures in memory as
%   a persistent variable. Between sessions, the function should always be
%   removed from memory. loadPTB and unloadPTB should handle this 
%   automatically, but if you're running into texture problems, this could 
%   be the cause.
%
% Arguments:
%   blockConfig (struct): a per-block configuration that is about to be
%     used to run a trial
%
% Returns:
%   blockConfig (struct): the same configuration with a valid window
%     pointer and newly loaded textures

persistent allTexturePointers;

% check with Screen('WindowKind')
validWindowPointers = Screen('Windows');
blockWindowPointer = blockConfig.device.windowPtr;
if ~ismember(blockWindowPointer, validWindowPointers)
  warning("The window pointer in the configuration was outdated.")
  if isempty(validWindowPointers)
    warning("There are no open windows. Opening...");
    blockConfig = loadPTB(blockConfig);
  else 
    warning("Connecting to an existing window...");
    % get the lowest pointer and check that the WindowSize/DisplaySize is correct
  end
end

% Get the textures
allTexturePointers = loadTexturesFromConfig(blockConfig, allTexturePointers);
blockConfig.runSetup.textures = allTexturePointers;

end

