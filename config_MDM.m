function s = config_MDM(changes)
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

s.default.bgrColor = [0 0 0];
% s.background.img = '';

%% Features of objects that your task displays
% This is the Wild West portion of property settings. s.(object) should contain
% whatever properties your drawX script will require to properly draw them. By
% current convention, this does not have to include specific coordinates, which
% your display script might calculate on the basis of specific device
% properties (like screen width & height). However, only the draw scripts you
% write will rely on these values; the way you choose to encode them in the
% settings is up to you. (This might change in future versions.)

% TODO: Re-write display functions to use getTextDims and deprecate this
s.objects.reference.misc.Digit1 = [31 30];
s.objects.reference.misc.Digit2 = [42 30];
s.objects.reference.dims = [50 100];
s.objects.reference.pos = [];
s.objects.reference.fontSize = s.default.fontSize;
s.objects.reference.fontColor = s.default.fontColor;
% s.objects.reference.img (src, dims, position)

s.objects.refProbabilities.fontSize = 10;
s.objects.refProbabilities.dims = [12 19];

s.objects.lottery.figure.dims = [150 300];
s.objects.lottery.figure.colors.prob = [255 0 0; 0 0 255];
s.objects.lottery.figure.colors.ambig = [127 127 127];

% TODO: Re-write display functions to use getTextDims and deprecate this
s.objects.lottery.stakes.misc.Digit1 = [64 64];
s.objects.lottery.stakes.misc.Digit2 = [92 64];
s.objects.lottery.stakes.misc.Digit3 = [120 64];
s.objects.lottery.stakes.fontSize = s.default.fontSize;
s.objects.lottery.stakes.fontColor = s.default.fontColor;

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
s.objects.feedback.shape = 'Rect';

s.objects.intertrial.color = [255 255 255];
s.objects.intertrial.shape = 'Oval';
s.objects.intertrial.dims = [40 40];

%% Non-display settings for the game
% Same Wild-West rules apply -- the format can be whatever you end up using

% (Maximum) durations of the various stages, in seconds
s.game.durations.choice = 6;
s.game.durations.response = 3.5;
s.game.durations.feedback = 0.5;
s.game.durations.ITIs = 2;
% These have to be in each block, in some order -- in most fMRI block designs,
% the block has to be constant. Some designs might want to shuffle these in
% particular ways, just like items in `s.game.levels`; other designs might want
% to omit ITIs altogether.

s.game.colorKey = {'blue', 'red'};
% Deprecated. This is remnant of the way the script used to be written -- it
% might be useful for those who wish to (for example) automatically replace
% `colors` value used in data collection with the actual color used.

%% Block properties
% Naming. Useful to quickly identify the properties used to run a trial -- it's
% to your benefit to make sure that this uniquely identifies your setting for
% the specific task and task block
s.game.name = 'MDM';
s.game.block.name = 'Medical';

% Useful for generation purposes
s.game.block.length = 10;
s.game.block.repeatIndex = NaN; % where will the test of stochastic dominance be
% FIXME: The repeating row should be explicitly defined here?

%% Available trial values
% Up to you how you use these -- it's suggested that you pass them to a trial
% generating function that will re-make them into an orderly shuffled table
s.game.levels.stakes = 1:5; % Levels are translated via lookup table
s.game.levels.probs = [.25 .5 .75];
s.game.levels.ambigs = [.24 .5 .74];
s.game.levels.stakes_loss = 1;
s.game.levels.reference = 2;
s.game.levels.colors = [1 2];
s.game.levels.repeats = 1;

%% MDM lookup tables
s.lookups.stakes.txt = {'no effect'; ...
  'slight improvement'; 'moderate improvement'; 'major improvement'; ...
  'recovery'};
s.lookups.stakes.img = {'symbol/no effect.jpg'; ...
  'symbol/slight improvement.jpg'; 'symbol/moderate improvement.jpg'; ...
  'symbol/major improvement.jpg'; 'symbol/recovery.jpg'};

%% Paint functions
% If you wish to re-use the standard monetary R&A task design, but with a
% slightly different way of drawing things, write your own functions (modeled,
% perhaps on `RA_drawTrial.m`), and supply the function handles here.
%
% Currently, these are local functions - which know what subparts they need. In
% the future, namespacing or loading from a subfolder will be encouraged.
s.game.trialFn = @RA_drawTrial;
s.game.preBlockFn = @RA_preBlock;
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
