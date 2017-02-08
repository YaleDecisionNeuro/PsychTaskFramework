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

%%% Defaults
% TODO: All the graphical settings should be a class enforcing fieldnames, etc.
% TODO: (That way, they can actually inherit from default.)
% (Or at least, create a skeleton of a struct to provide guidance.)

%% Machine settings
% This is where you set properties important for PsychToolBox to function
% properly. Consult PTB manual if these are unclear.
s.device.KbName = 'KeyNamesWindows';
s.device.screenId = 1; % 0 for current screen, 1 for a second screen
s.device.windowPtr = NaN; % Must get filled in with Screen('Open')
s.device.screenDims = []; % Must get filled in with Screen('Open')
s.device.sleepIncrements = 0.01; % In seconds, how often do we check for keyboard presses, or whether enough time elapsed in a period? 0 for as often as possible

%% Graphics defaults
% To prevent yourself from having to change many settings in many places, use
% `s.default.X` to define property `X` for a particular display feature. This
% way, you'll only have to change it in one spot,
s.default.fontName = 'Arial';
s.default.fontColor = [255 255 255];
s.default.fontSize = 42;

s.background.color = [0 0 0];
s.background.img = NaN;
% background.img.src, dims, position
% TODO: There has to be a better way to deal with images

%% Features of objects that your task displays
% This is the Wild West portion of property settings. s.(object) should contain
% whatever properties your drawX script will require to properly draw them. By
% current convention, this does not have to include specific coordinates, which
% your display script might calculate on the basis of specific device
% properties (like screen width & height). However, only the draw scripts you
% write will rely on these values; the way you choose to encode them in the
% settings is up to you. (This might change in future versions.)

s.objects.reference.misc.Digit1 = [31 30];
s.objects.reference.misc.Digit2 = [42 30];
% TODO: Position stemming from text width should be derived in the process?
s.objects.reference.dims = [50 100];
s.objects.reference.pos = [];
s.objects.reference.fontSize = s.default.fontSize;
s.objects.reference.fontColor = s.default.fontColor;
s.objects.reference.format = '-$%d';
% s.objects.reference.img (src, dims, position)

s.objects.refProbabilities.fontSize = 10;
s.objects.refProbabilities.dims = [12 19];

s.objects.lottery.figure.dims = [150 300];
s.objects.lottery.figure.colors.prob = [255 0 0; 0 0 255];
s.objects.lottery.figure.colors.ambig = [127 127 127];

% FIXME: This is really the sort of a thing that should be delegated to
% display functions
s.objects.lottery.stakes.misc.Digit1 = [64 64];
s.objects.lottery.stakes.misc.Digit2 = [92 64];
s.objects.lottery.stakes.misc.Digit3 = [120 64];
s.objects.lottery.stakes.fontSize = s.default.fontSize;
s.objects.lottery.stakes.fontColor = s.default.fontColor;
s.objects.lottery.stakes.posTop = []; % to be computed later?
s.objects.lottery.stakes.posBottom = []; % to be computed later?
s.objects.lottery.stakes.format = '-$%d';
% TODO: Different format for zero and non-zero? -$0 looks odd

s.objects.lottery.probLabels.fontSize = 20;
s.objects.lottery.probLabels.fontColor = s.default.fontColor;
s.objects.lottery.probLabels.dims = [31 30];

s.objects.prompt.dims = [40 40];
s.objects.prompt.color = [0 255 0];
s.objects.prompt.pos = 'center'; % TODO: This should be a special value
s.objects.prompt.shape = 'Oval';

s.objects.feedback.colorNoAnswer = [255 255 255];
s.objects.feedback.colorAnswer = [255 255 0];
s.objects.feedback.dims = [40 40];
s.objects.feedback.pos = []; % to be computed
s.objects.feedback.shape = 'Rect';

s.objects.intertrial.color = [255 255 255];
s.objects.intertrial.shape = 'Oval';
s.objects.intertrial.dims = [40 40];
%% Game-specific settings -- for all trials in the block
% FIXME: should these be with
s.game.responseWindowDur = 3.5; % 0 means indefinite
s.game.feedbackDur = .5;
s.game.choiceDisplayDur = 6;

s.game.durations.choice = 6;
s.game.durations.response = 3.5;
s.game.durations.feedback = 0.5;
s.game.durations.ITIs = [10, 4 * ones(1, 10), 6 * ones(1, 10), 8 * ones(1, 10)];
% These have to be in each block, in some order -- in most fMRI block designs, the block has to be constant.
% TODO: Move to s.game.levels?

s.game.colorKey = {'blue', 'red'}; % Useful?

s.game.block.type = 'Gains';
s.game.block.length = 31;
s.game.block.repeatIndex = 1; % where will the test of stochastic dominance be
s.game.levels.stakes = [5, 6, 7, 8, 10, 12, 14, 16, 19, 23, 27, 31, 37, 44, 52, 61, 73, 86, 101, 120];
s.game.levels.probs = [.25 .5 .75];
s.game.levels.ambigs = [.24 .5 .74];
s.game.levels.stakes_loss = 0;
s.game.levels.reference = 5;
s.game.levels.colors = [1 2];
s.game.levels.repeats = 1;

s.game.trialFn = @RA_drawTrial; % currently a local function - and it knows what subparts it needs?
% s.game.preBlockFn = @someFn;
% s.game.postBlockFn = @someFn;

%% Changes
% FIXME: This fails with sub-subfields, or rather, replaces them wholesale
% TODO: Make recursive
% TODO: Scream when changes contains a field that the skeleton doesn't
if exist('changes', 'var')
  props = fieldnames(changes);
  for i = 1:numel(props)
    % s.(props{i}) = changes.(props{i});
  end
end

end
