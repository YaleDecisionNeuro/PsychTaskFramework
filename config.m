function s = config(windowPtr, changes)
% Return default settings for the block. If changes is provided
% as a `struct` with same field names, the values are overwritten.
%
% Colors, when given, are RGB colors. PTB also accepts RGBA and CLUT.
%
% TODO: Persistence - in a `.mat` file, or `.json`? Or instruct people to edit
% *this*? Either way, there should be a loud complaint if there's `changes`,
% and possibly a question as to whether `changes` should persist.
% (Or maybe load from `.json` and save into `.mat`, which gets deleted after
% every user.)
% TODO: Implement `changes` -- a recursive sweep through
% TODO: Spec out windowPtr: obtains info via something like
%   `function screenInfo = extract(windowPtr)`

%%% Defaults
% TODO: All the graphical settings should be a class enforcing fieldnames, etc.
% TODO: (That way, they can actually inherit from default.)
% (Or at least, create a skeleton of a struct to provide guidance.)

%% Machine settings
s.device.KbName = 'KeyNamesWindows';
s.device.screenId = 1; % 0 for current screen
s.device.screenDims = [1280 1024]; % should get filled in with Screen('Open') if empty
s.device.sleepIncrements = 0; % How often do we check for keyboard presses, or whether enough time elapsed in a period? 0 for as often as possible

s.default.fontName = 'Arial';
s.default.fontColor = [255 255 255];
s.default.fontSize = 42;

s.background.color = [0 0 0];
s.background.img = NaN;
% background.img.src, dims, position
% TODO: There has to be a better way to deal with images

% TODO: This should be derived in the process
s.reference.misc.Digit1 = [31 30];
s.reference.misc.Digit2 = [42 30];
s.reference.dims = [50 100];
s.reference.pos = [];
s.reference.fontSize = s.default.fontSize;
s.reference.fontColor = s.default.fontColor;
s.reference.format = '-$%d';
% s.reference.img (src, dims, position)
% inheriting font from default

s.refProbabilities.fontSize = 10;
s.refProbabilities.dims = [12 19];

s.lottery.figure.dims = [150 300];
s.lottery.figure.colors.prob = [255 0 0; 0 0 255];
s.lottery.figure.colors.ambig = [127 127 127];

% FIXME: This is really the sort of a thing that should be delegated to
% display functions
s.lottery.stakes.misc.Digit1 = [64 64];
s.lottery.stakes.misc.Digit2 = [92 64];
s.lottery.stakes.misc.Digit3 = [120 64];
s.lottery.stakes.fontSize = s.default.fontSize;
s.lottery.stakes.fontColor = s.default.fontColor;
s.lottery.stakes.posTop = []; % to be computed later?
s.lottery.stakes.posBottom = []; % to be computed later?
s.lottery.stakes.format = '-$%d';
% TODO: Different format for zero and non-zero? -$0 looks odd

s.lottery.probLabels.fontSize = 20;
s.lottery.probLabels.fontColor = s.default.fontColor;
s.lottery.probLabels.dims = [31 30];

s.prompt.dims = [40 40];
s.prompt.color = [0 255 0];
s.prompt.pos = 'center'; % TODO: This should be a special value
s.prompt.shape = 'Oval';

s.feedback.colorNoAnswer = [255 255 255];
s.feedback.colorAnswer = [255 255 0];
s.feedback.dims = [40 40];
s.feedback.pos = []; % to be computed
s.feedback.shape = 'Rect';

s.intertrial.color = [255 255 255];
s.intertrial.shape = 'Oval';
s.intertrial.dims = [40 40];
%% Game-specific settings -- for all trials in the block
% FIXME: should these be with
s.game.responseWindowDur = 3.5; % 0 means indefinite
s.game.feedbackDur = .5;
s.game.choiceDisplayDur = 6;

s.game.colorKey = {'blue', 'red'}; % Useful?

s.game.blockType = 'Gains';
s.game.trialFn = @RA_drawTrial; % currently a local function - and it knows what subparts it needs?
% s.game.preBlockFn = @someFn;
% s.game.postBlockFn = @someFn;
s.game.stakes = [5 16 19];
s.game.fails = 0; % but could be a 1xn matrix
s.game.reference = 5; % but could be a 1xn matrix
s.game.probs = [.5 .5 .25];
s.game.ambigs = [0 .24 0];
s.game.ITIs  = [8 4 8];
s.game.colors = [2 1 2];
s.game.numTrials = length(s.game.stakes); % FIXME: Should be the longest of the above?
% TODO: Should probably automatically `repmat` any shorter fields (and warn about that). Or, rather, should be handled in its own constructor. But this will do for now.

% s.game.trials = table(s.game.stakes', s.game.probs', s.game.ambigs');
%% Changes
% FIXME: This fails with sub-subfields, or rather, replaces them wholesale
% TODO: Make recursive
% TODO: Scream when changes contains a field that the skeleton doesn't
if exist('changes', 'var')
  props = fieldnames(changes);
  for i = 1:numel(props)
    s.(props{i}) = changes.(props{i});
  end
end

end
