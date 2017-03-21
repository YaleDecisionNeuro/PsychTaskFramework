function [ settings ] = loadPTB(settings)
% Start PsychToolBox; return settings struct with display info.
%
% Most importantly, the display info is in settings.device; the essential one
%   is s.device.windowPtr.

%% Set random seed -- if already set, continue using that one
if exist('RandStream', 'var') % Not on Octave
  if ~isfield(settings.device, 'rngAlgorithm')
    settings.device.rngAlgorithm = 'mt19937ar'; % MATLAB default
  end
  if ~isfield(settings.device, 'rngSeed')
    settings.device.rngSeed = sum(100 * clock);
  end
  seed = RandStream.create(settings.device.rngAlgorithm, ...
    'seed', settings.device.rngSeed);
  RandStream.setGlobalStream(seed);
end

%% Set the keyboard layout
if ~isfield(settings.device, 'KbName')
  settings.device.KbName = 'UnifyKeyNames';
end
KbName(settings.device.KbName);

%% Invoke PTB debug configuration if debug mode is set
if isfield(settings, 'debug') && settings.debug == true
  PsychDebugWindowConfiguration();
end

%% Open the window
if ~isfield(settings.device, 'screenId')
  settings.device.screenId = max(Screen('Screens'));
end
if ~isfield(settings.graphicDefault, 'bgrColor')
  settings.device.bgrColor = [0 0 0];
end

if isfield(settings.device, 'screenDims') && ...
   numel(settings.device.screenDims(:)) == 4
  % Only open a partial screen
  [settings.device.windowPtr, settings.device.screenDims] = ...
    Screen('OpenWindow', settings.device.screenId, ...
    settings.graphicDefault.bgrColor, settings.device.screenDims);
else
  [settings.device.windowPtr, settings.device.screenDims] = ...
    Screen('OpenWindow', settings.device.screenId, ...
    settings.graphicDefault.bgrColor);
end

windowRect = settings.device.screenDims;
settings.device.windowWidth  = windowRect(3) - windowRect(1);
settings.device.windowHeight = windowRect(4) - windowRect(2);
end
