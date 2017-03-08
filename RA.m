function RA(observer)
% RA Runs the right scripts (Day 1 or Day 2, order by condition) for VA_RA_PTB.
%
% Does the work of "what script to run" behind the screens. Is agnostic as to
%   what the scripts it runs contain.
%
% NOTE: v7 scripts save after every trial, which is the right impulse, but
%   there's currently no way to jump to n-th trial or even second block of the
%   two-block script. If this script is run, the experimenter presumably wants
%   to collect the data anew -- but since there might have been a reason to
%   save the choices thus far, this script backs up the data folder before
%   clobbering the recorded-but-incomplete block.

%% 1. Get records from data files, if available
dataFolder = fullfile('data', num2str(observer));
if ~exist(dataFolder, 'dir')
  mkdir(dataFolder);
  fprintf('No existing data file for %d at %s. Creating.\n', observer, dataFolder);
end

[gainsBlockCount, lossBlockCount, dateBegun] = getInfoFromDataFiles(observer);
if ~isnan(dateBegun)
  fprintf('Reading existing data files from %s; experiment started on %s\n', ...
    dataFolder, dateBegun);
end

%% 2. Back up data folder (with all participant records)
if ~exist('backup', 'dir')
  mkdir('backup');
end
copyfile('data', fullfile('backup', sprintf('data-%s', datetime)));

%% 3. Handle the incomplete-blocks case
uninterruptedN = [0 2 4];
if ~ismember(gainsBlockCount, uninterruptedN) || ...
   ~ismember(lossBlockCount, uninterruptedN)
  contCheck = input(sprintf(['Participant %d has %.2f gains blocks and ', ...
    '%.2f loss blocks. Continuing will overwrite some recorded choices. ', ...
    'Do you wish to back up the data folder at this point and continue? ', ...
    ' [y/[n]]'], observer, gainsBlockCount, lossBlockCount), 's');
  if strcmp(contCheck, 'y')
    copyfile(dataFolder, sprintf('%s-partial-%.1fG-%.1fL', dataFolder, ...
      gainsBlockCount, lossBlockCount));
  else
    error('You chose to abort the script.');
  end
end

%% 4. What order should the blocks be run in?
% Define functions (as their versions change)
gains1 = @RA_Gains1_v7;
gains2 = @RA_Gains2_v7;
loss1 = @RA_Loss1_v7;
loss2 = @RA_Loss2_v7;

% Order their run
lastDigit = mod(observer, 10);
lossStartDigits = [1 2 5 6 9];
if ismember(lastDigit, lossStartDigits)
  runFunctions = {loss1, gains1, gains2, loss2};
else
  runFunctions = {gains1, loss1, loss2, gains2};
end
% runFunctions{i}(observer) will run the script at i-th position

%% 5. If the case is covered, run the requisite scripts
% Case for aborting: all records already collected
if gainsBlockCount == 4 && lossBlockCount == 4
  % Everything recorded
  error('Participant %d has full records from both sessions. Aborting.', observer);
end

% Runnable cases. Check with experimenter first!
% NOTE: Using `xor` means that no weird edge cases slip through. Even if someone
%   e.g. had all gains blocks and no loss blocks recorded, this should force
%   them to record the loss blocks.
if gainsBlockCount < 2 && lossBlockCount < 2
  % No records yet -> run Day 1
  response = input(sprintf('Participant %d is new. Continue? (y/[n])', ...
    observer), 's');
  if strcmp(response, 'y')
    runFunctions{1}(observer);
    runFunctions{2}(observer);
  end
elseif xor(gainsBlockCount < 2, lossBlockCount < 2)
  % Only one domain of Day 1 -> run the other domain
  response = input(sprintf(['Participant %d has an incomplete Day 1 ', ...
    'session (two blocks). Collect the rest? (y/[n])'], observer), 's');
  if strcmp(response, 'y')
    if gainsBlockCount < 2
      gains1(observer);
    else
      loss1(observer);
    end
  end
elseif gainsBlockCount < 4 && lossBlockCount < 4
  % All of Day 1, none of Day 2 -> run Day 2
  response = input(sprintf(['Participant %d appears to have done Session 1. ', ...
    'Continue with Session 2? (y/[n])'], observer), 's');
  if strcmp(response, 'y')
    runFunctions{3}(observer);
    runFunctions{4}(observer);
  end
elseif xor(gainsBlockCount < 4, lossBlockCount < 4)
  % Some of Day 2, but not all
  response = input(sprintf(['Participant %d has an incomplete Day 2. ', ...
    'Collect the rest? (y/[n])'], observer), 's');
  if strcmp(response, 'y')
    if gainsBlockCount < 4
      gains2(observer);
    else
      loss2(observer);
    end
  end
else
  error('Something odd happened. Run individual block scripts instead.');
end

if ~strcmp(response, 'y')
  error('Double-check participant ID or downgrade to individual block scripts.');
end
end

%% Helper functions
function [ gainsBlockCount, lossBlockCount, dateBegun ] = getInfoFromDataFiles(observer)
% getInfoFromDataFiles Loads available data files and counts recorded blocks.
folder = fullfile('data', num2str(observer), 'RA_%s_%d.mat');
lossFile = sprintf(folder, 'LOSS', observer);
gainsFile = sprintf(folder, 'GAINS', observer);

dateFormat = 'yyyymmddThhMMss';
if exist(lossFile, 'file')
  lossData = getfield(load(lossFile, 'Data'), 'Data');
  lossDate = datenum(lossData.date, dateFormat);
  lossBlockCount = numTrialsToBlocks(lossData.choice);
else
  lossDate = Inf;
  lossBlockCount = 0;
end

if exist(gainsFile, 'file')
  gainsData = getfield(load(gainsFile, 'Data'), 'Data');
  gainsDate = datenum(gainsData.date, dateFormat);
  gainsBlockCount = numTrialsToBlocks(gainsData.choice);
else
  gainsDate = Inf;
  gainsBlockCount = 0;
end

if isinf(lossDate) && isinf(gainsDate)
  dateBegun = NaN;
else
  dateBegun = datestr(min(lossDate, gainsDate));
end
end

function [ numBlocks ] = numTrialsToBlocks(choiceData, trialsPerBlock)
% numTrialsToBlocks From participant choices, infer the number of blocks recorded.
%
% If `trialsPerBlock` is not provided, it assumes that there are 31 per block.
if ~exist('trialsPerBlock', 'var')
  trialsPerBlock = 31;
end
numBlocks = length(choiceData) / trialsPerBlock;
end
