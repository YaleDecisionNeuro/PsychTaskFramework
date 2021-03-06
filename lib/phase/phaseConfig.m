function [ phaseConfig ] = phaseConfig(name, varargin)
% Prepares a uniform structure for the definition of a phase.
%
% Args:
%   name: The phase name or ID
%   'PropertyName1', 'PropertyValue1', ...: Any number of phase configuration
%     properties
% 
% Returns:
%   phaseConfig: The phase settings.

defaultDuration = Inf;
defaultPhaseScript = @phase_generic; % Good enough for run of the mill processing
defaultAction = @action_waitForBreak;

p = inputParser;
addRequired(p, 'name', @ischar);
addOptional(p, 'duration',  defaultDuration, @isnumeric);
addOptional(p, 'phaseScript', defaultPhaseScript, @isFunction);
addOptional(p, 'action', defaultAction, @isFunctionOrFunctionArray);
addOptional(p, 'drawCmds', {}, @isFunctionOrFunctionArray);

parse(p, name, varargin{:});
phaseConfig = p.Results;
end
