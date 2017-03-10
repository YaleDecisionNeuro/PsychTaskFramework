function s = config(changes)
% CONFIG Return default settings *for the block*. If changes is provided
%   as a `struct` with same field names, the values are overwritten. (NOTE: This
%   is not implemented yet -- if you need to alter values for a block, you'll
%   need to directly alter the struct that this function returns! If you need to
%   do this regularly, consider splitting this off to a separate `config`-like
%   function that either (a) calls `config`, alters the values, then returns
%   them, or less preferable (b) is a copy of this file.)
%
% The default err on the side of catering to LevyLab's R&A paradigm. If you're
% not using it, nuke s.objects from high orbit.
%
% Colors, when given, are RGB colors. PTB also accepts RGBA and CLUT.
%
% TODO: Implement `changes` -- a recursive sweep through

%%% Defaults
% TODO: All the graphical settings should be a class enforcing fieldnames, etc.
% TODO: (That way, they can actually inherit from default.)
% (Or at least, create a skeleton of a struct to provide guidance.)

%% Machine settings
% This is where you set properties important for PsychToolBox to function
% properly. Consult PTB manual if these are unclear.
s.device.KbName = 'KeyNamesWindows';
s.device.screenId = max(Screen('Screens'));
s.device.windowPtr = NaN; % Must get filled in with Screen('Open')
s.device.screenDims = NaN; % Must get filled in with Screen('Open')
s.device.sleepIncrements = 0.01; % In seconds, how often do we check for keyboard presses, or whether enough time elapsed in a period? 0 for as often as possible
s.device.saveAfterBlock = true; % Should runBlock automatically save?

%% Graphics defaults
% To prevent yourself from having to change many settings in many places, use
% `s.default.X` to define property `X` for a particular display feature. This
% way, you'll only have to change it in one spot,
s.default.fontName = 'Arial';
s.default.fontColor = [255 255 255];
s.default.fontSize = 42;
s.default.bgrColor = [0 0 0];

%% Features of objects that your task displays
% This is the Wild West portion of property settings. s.(object) should contain
% whatever properties your drawX script will require to properly draw them. By
% current convention, this does not have to include specific coordinates, which
% your display script might calculate on the basis of specific device
% properties (like screen width & height). However, only the draw scripts you
% write will rely on these values; the way you choose to encode them in the
% settings is up to you. (This might change in future versions.)

% FIXME: Deprecate in favor of getTextDims
s.objects.reference.misc.Digit1 = [31 30];
s.objects.reference.misc.Digit2 = [42 30];
s.objects.reference.dims = [50 100];
s.objects.reference.fontSize = s.default.fontSize;
s.objects.reference.fontColor = s.default.fontColor;

s.objects.lottery.figure.dims = [150 300];
s.objects.lottery.figure.colors.prob = [255 0 0; 0 0 255];
s.objects.lottery.figure.colors.ambig = [127 127 127];

% FIXME: Deprecate in favor of getTextDims
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

% (Maximum) durations of the various stages
s.game.constantTrialDuration = false;
s.game.durations.choice = 6;
s.game.durations.response = 3.5;
s.game.durations.feedback = 0.5;
s.game.durations.ITIs = [4 * ones(1, 10), 6 * ones(1, 10), 8 * ones(1, 10)];
% These have to be in each block, in some order -- in most fMRI block designs,
% the block has to be constant. Some designs might want to shuffle these in
% particular ways, just like items in `s.game.levels`; other designs might want
% to omit ITIs altogether.
%
% However, current method of shuffling ITIs will work as long as their number
% divides the number of trials within a block without remainder.

s.game.colorKey = {'blue', 'red'};
% Deprecated. This is remnant of the way the script used to be written -- it
% might be useful for those who wish to (for example) automatically replace
% `colors` value used in data collection with the actual color used.

%% Block properties
% Naming. Useful to quickly identify the properties used to run a trial -- it's
% to your benefit to make sure that this uniquely identifies your setting for
% the specific task and task block
s.game.name = NaN;
s.game.block.name = NaN;
s.game.block.length = 1;

% NOTE: If you have a trial you'd like to repeat in every trial in a particular
%   place in the block, you'll define it in .repeatTrial and the in-block
%   position(s) in .repeatIndex
% s.game.block.repeatIndex = NaN;
% s.game.block.repeatTrial = [];

%% Available trial values
% Up to you how you use these -- it's suggested that you pass them to a trial
% generating function that will re-make them into an orderly shuffled table
%
% The following values are just samples of what you can use.
s.game.levels.stakes = [5, 6, 7, 8];
s.game.levels.probs = [.25 .5 .75];
s.game.levels.ambigs = [.24 .5 .74];
s.game.levels.stakes_loss = 0;
s.game.levels.reference = 5;
s.game.levels.colors = [1 2];
s.game.levels.repeats = 1;

%% Paint functions
% To re-use the infrastructure this framework provides, you can supply only the
% change that you need for your own task. You can do this by providing a
% "function handle" - a reference to a function you wrote preceded by the @
% sign. (For the monetary decision-making task, this would be @RA_drawTask. You
% can learn more about function handles at
% https://www.mathworks.com/help/matlab/matlab_prog/creating-a-function-handle.html.)
%
% IMPORTANT: These are *crucial* items to set, as they define what components
% your task will be using.
%
% NOTE: It is important to ensure that whatever trial script you'll be using
% will be on the MATLAB path, i.e. added with `addpath(script_location)`.

% %% Trial scripts: trialFn
% trialFn defines what trial script each `runBlock` should use to conduct the
% trials. The trial script is responsible for the order in which task phases
% are invoked.
%
% If you wish to re-use the standard R&A task designs, you'll want to keep this
% set to @runTrial (which you can find in lib/phase).

s.game.trialFn = @runTrial;

% %% Phase scripts
% If you're only changing an element of the task, but you're happy with the
% standard order of phases (i.e. choice display, response prompt, feedback,
% intertrial), you can substitute a function here. It should take, and return,
% the same arguments that the phase function in lib/phase does. (In general,
% this is `sampleFn(trialData, trialSettings, blockSettings, callback)`.)
%
% By design, optionsPhaseFn is left blank. `runTrial` will complain if it is
% not set, or if any of the phase function handles below are unset. While you
% might avoid setting it by writing your own trial script, it is recommended
% that you still leverage these settings; it will make your task easier to
% maintain and understand for your collaborators.
%
% (You might be able to re-use the functions written specifically for monetary
% or medical choices, which you can find in tasks/[folder].)

s.game.optionsPhaseFn = NaN;
s.game.responsePhaseFn = @handleResponse;
s.game.feedbackPhaseFn = @drawFeedback;
s.game.intertrialPhaseFn = @drawIntertrial;

% %% Reference draw script
% Reference draw script defines how the "reference" (value alternative to the
% gamble) will be drawn. It is specific to the kind of choices you present. Its
% default arguments are drawRef(blockSettings, trialSettings).

s.game.referenceDrawFn = NaN;

% %% Background draw script
% The default background draw script is called between the phases to set
% background and font properties back to default. You might wish to alter it
% to, e.g., to make sure that the reference is drawn at all times.
%
% By convention, the background draw script only takes block settings and a
% potential callback function as an argument, and does not access nor modify
% collected data.

s.game.bgrDrawFn = @drawBgr;

%% Event functions
% Functions that are automatically executed before and after every block these
% settings are applied to.

% @preBlock is a helpful default in `lib/phase` - displays block number before
% every block, waits for the press of '5%' button to start first trial.

s.game.preBlockFn = @preBlock;
s.game.postBlockFn = NaN;

%% Lookup tables
% If you're using any images or map your payoff values to a textual label,
% you'd define the lookup tables here! For an example, see MDM_config. For an
% explanation, see the README.

% s.lookups.stakes.txt = {'destitution', 'status quo', 'unimaginable riches'}

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
