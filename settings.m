function settings = config(changes)
% Return default settings. If changes is provided as a `struct` with same
% field names, the values are overwritten. TODO: Persistence - in a `.mat`
% file, or `.json`? Or instruct people to edit *this*? Either way, there
% should be a loud complaint if there's `changes`, and possibly a question
% as to whether `changes` should persist. (Or maybe load from `.json` and
% save into `.mat`, which gets deleted after every user.)

% FIXME: Get stuff from `setParams_LSRA`
settings.colorKey = {'blue', 'red'}; % Unordered, and is this useful?
% FIXME: Initialize `.stimulus`
settings.stimulus.responseWindowDur = 3.5;
settings.stimulus.feedbackDur = .5;
settings.stimulus.lottoDisplayDur = 6;

settings.vals = [5 16 19 111 72 9]';
settings.probs = [.5 .5 .25 .5 .25 .5]';
settings.ambigs = [0 .24 0 .74 0 .24]';
settings.numTrials = length(settings.vals);
settings.ITIs  = [8 4 8 6 4 8];
settings.colors = [2 1 2 1 2 2];
end
