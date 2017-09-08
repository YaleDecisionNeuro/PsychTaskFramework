function [ bool ] = configHasLookups(config)
% Checks if lookups exist and are non-empty. (Tests presence of image payoffs.)
%
% The function is commonly used to detect if the config defines an image + text
% value to substitute for the value in trialData specification.
%
% Args: 
%   config: Block configuration
%
% Returns:
%   bool: Boolean true if lookups field is present and contains content.
bool = false;

% Does the field even exist?
if ~isfield(config, 'runSetup') || ~isfield(config.runSetup, 'lookups')
  return;
end

% Does it contain a non-empty struct?
if isempty(config.runSetup.lookups) || ~isstruct(config.runSetup.lookups)
  return;
end

% Do the fields contain anything? If so, config has lookups!
lengths = structfun(@numel, config.runSetup.lookups);
if sum(lengths) > 0
  bool = true;
end
end
