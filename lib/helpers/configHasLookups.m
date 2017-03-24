function [ bool ] = configHasLookups(config)
% Checks if lookups exist and are non-empty.
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
