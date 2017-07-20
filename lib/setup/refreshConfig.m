function [ blockConfig ] = refreshConfig( blockConfig )
% Connects to a valid PTB screen window with valid PTB textures.
%
% refreshConfig replaces the need for explicit loadPTB and
% loadTexturesFromConfig calls by calling them when necessary. It does the
% following things:
% 
% 1. Stores the textures loaded so far in a variable that persists across
%    function calls, re-creating them when needed,
% 2. Connects to the last on-screen window that PTB has opened if the 
%    configuration does not have a valid window pointer, or opens a new 
%    on-screen window (via `loadPTB`) if there is none,
% 3. Re-creates the textures if any of them is invalid, or made from a 
%    connection to an invalid PTB window.
%
% Note: refreshConfig holds all previously generated textures in memory as
%   a persistent variable. Between sessions, the function should always be
%   removed from memory. loadPTB and unloadPTB handle this, but if you're 
%   running into texture problems, this could be the cause.
%
% Arguments:
%   blockConfig (struct): a per-block configuration that is about to be
%     used to run a trial
%
% Returns:
%   blockConfig (struct): the same configuration with a valid window
%     pointer and newly loaded textures

persistent allTexturePointers;

% check with Screen('WindowKind'):
%   "Returns 0 if it's invalid, -1 an offscreen window or a normal texture,
%   1 our onscreen, 2 Matlab's onscreen, 3 a non-redrawable texture, 4 a
%   proxy window." We only want status 1 (status 2 is outdated) for window
%   pointers, status -1 for textures.

allPointers = Screen('Windows'); % Does this include textures? Yes!
windowKinds = Screen(allPointers, 'WindowKind');
validWindowPointers = allPointers(windowKinds == 1);

blockWindowPointer = blockConfig.device.windowPtr;
if ~isempty(blockWindowPointer) && ~isnan(blockWindowPointer)
  pointerStatus = Screen(blockWindowPointer, 'WindowKind');
else
  pointerStatus = 0;
end

%% 1. Check window pointer
if pointerStatus ~= 1
  blockConfig.runSetup.textures = cell.empty;
  if ~isempty(validWindowPointers)
    disp('Connecting to an existing window...');
    blockConfig.device.windowPtr = validWindowPointers(end);
    % FIXME: Should check that WindowSize is equal to previous value
    [blockConfig.device.windowWidth, blockConfig.device.windowHeight] = ...
      Screen('WindowSize', blockConfig.device.windowPtr);
  else
    disp('There are no open windows. Opening...');
    blockConfig = loadPTB(blockConfig);
    allTexturePointers = [];
  end
end

%% 2. Check textures
validTexturePointers = allPointers(windowKinds == -1);
if isfield(blockConfig.runSetup, 'textures') && ...
    isa(blockConfig.runSetup.textures, 'containers.Map')
  textureIds = cellfun(@(x) x.textureId, ...
    blockConfig.runSetup.textures.values, 'UniformOutput', true);
  texturesToPurge = ~ismember(textureIds, validTexturePointers);
  % if one is invalid, purge all
  if sum(texturesToPurge) > 0
    disp('One or more textures were invalid; reloading...');
    blockConfig.runSetup.textures = cell.empty;
  end
end

% FIXME: Should we also check that all images in blockConfig are
% contained in allTexturePointers, given that this might be the primary
% method of texture assignment and their absence would suggest that despite
% having valid pointers, they're not actually corresponding to the image
% files that we want to represent?
%
% My hunch is that no: in the call below, allTexturePointers is actually
% taken as a base and every filename that is used as a key has a texture
% created for it, which is then used by the blockConfig. That said, it
% would be nice to test that hunch.

%% 3. Load whatever textures are necessary
% Get the textures
allTexturePointers = loadTexturesFromConfig(blockConfig, allTexturePointers);
blockConfig.runSetup.textures = allTexturePointers;
end

