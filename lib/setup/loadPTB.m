function [ config ] = loadPTB(config)
% Start PsychToolBox; return config struct with display info.
%
% Most importantly, the display info is in config.device; the essential one
%   is s.device.windowPtr.
%
% Args:
%   config: A configuration of PTB set-up
%
% Returns:
%   config: A configuration of PTB set-up 

%% Set random seed -- if already set, continue using that one
if exist('RandStream', 'var') % Not on Octave
  if ~isfield(config.device, 'rngAlgorithm')
    config.device.rngAlgorithm = 'mt19937ar'; % MATLAB default
  end
  if ~isfield(config.device, 'rngSeed')
    config.device.rngSeed = sum(100 * clock);
  end
  seed = RandStream.create(config.device.rngAlgorithm, ...
    'seed', config.device.rngSeed);
  RandStream.setGlobalStream(seed);
end

%% Set the keyboard layout
KbName('UnifyKeyNames');

%% Invoke PTB debug configuration if debug mode is set
if isfield(config, 'debug') && config.debug == true
  PsychDebugWindowConfiguration();
end

%% Open the window
if ~isfield(config.device, 'screenId')
  config.device.screenId = max(Screen('Screens'));
end
if ~isfield(config.graphicDefault, 'bgrColor')
  config.device.bgrColor = [0 0 0];
end

if isfield(config.device, 'screenDims') && ...
   numel(config.device.screenDims(:)) == 4
  % Only open a partial screen
  [config.device.windowPtr, config.device.screenDims] = ...
    Screen('OpenWindow', config.device.screenId, ...
    config.graphicDefault.bgrColor, config.device.screenDims);
else
  [config.device.windowPtr, config.device.screenDims] = ...
    Screen('OpenWindow', config.device.screenId, ...
    config.graphicDefault.bgrColor);
end

windowRect = config.device.screenDims;
config.device.windowWidth  = windowRect(3) - windowRect(1);
config.device.windowHeight = windowRect(4) - windowRect(2);
end
