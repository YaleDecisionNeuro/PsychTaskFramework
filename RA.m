function RA(observer)
% RA Runs the right scripts (Day 1 or Day 2, order by condition) for VA_RA_PTB.
%
% Does the work of "what script to run" behind the screens. Is agnostic as to
%   what the scripts it runs contain.
%
% NOTE: v7 scripts save after every trial, which is the right impulse, but
%   there's currently no way to jump to n-th trial or even second block of
%   the two-block script. If this script is run, the experimenter presumably
%   wants to collect the data anew -- but since there might have been a reason
%   to save the choices thus far, this script refuses to go on if there's more
%   than half a block recorded.
% FIXME: The correct way to handle this is to copy the data file & clearly name
%   it, then purge the items that have to be clobbered and go on.

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

% Check that the script can handle this
knownN = [0 2 4];
if ~ismember(gainsBlockCount, knownN) || ~ismember(lossBlockCount, knownN)
  error(['Ineligible number of recorded blocks: %d gains & %d loss blocks.', ...
    ' This should not happen.'], gainsBlockCount, lossBlockCount);
end

%% 2. Back up data folder
if ~exist('backup', 'dir')
  mkdir('backup');
end
copyfile('data', fullfile('backup', sprintf('data-%s', datetime)));

%% 3. What order should the blocks be run in?
lastDigit = mod(observer, 10);
lossStartDigits = [1 2 5 6 9];
if ismember(lastDigit, lossStartDigits)
  runFunctions = {@RA_Loss1_v7, @RA_Gains1_v7, @RA_Gains2_v7, @RA_Loss2_v7};
else
  runFunctions = {@RA_Gains1_v7, @RA_Loss1_v7, @RA_Loss2_v7, @RA_Gains2_v7};
end
% runFunctions{i}(observer) will run the script at i-th position

%% 4. If the case is covered, run the requisite scripts
% Case for aborting: all records already collected
if gainsBlockCount == 4 && lossBlockCount == 4
  % Everything recorded
  error('Participant %d has full records from both sessions. Aborting.', observer);
end

% Runnable cases. Check with experimenter first!
if gainsBlockCount + lossBlockCount == 0
  % No records yet
  response = input(sprintf('Participant %d is new. Continue? (y/[n])', ...
    observer), 's');
  if strcmp(response, 'y')
    runFunctions{1}(observer);
    runFunctions{2}(observer);
  end
elseif gainsBlockCount + lossBlockCount == 2
  % Only half of Day 1
  response = input(sprintf(['Participant %d has an incomplete Day 1 ', ...
    'session (two blocks). Collect the rest? (y/[n])'], observer), 's');
  if strcmp(response, 'y')
    if gainsBlockCount < 2
      RA_Gains1_v7(observer);
    else
      RA_Loss1_v7(observer);
    end
  end
elseif gainsBlockCount + lossBlockCount == 4
  % All of Day 1, none of Day 2
  response = input(sprintf(['Participant %d appears to have done Session 1. ', ...
    'Continue with Session 2? (y/[n])'], observer), 's');
  if strcmp(response, 'y')
    runFunctions{3}(observer);
    runFunctions{4}(observer);
  end
elseif gainsBlockCount + lossBlockCount == 6
  % Some of Day 2, but not all
  response = input(sprintf(['Participant %d has an incomplete Day 2. ', ...
    'Collect the rest? (y/[n])'], observer), 's');
  if strcmp(response, 'y')
    if gainsBlockCount < 4
      RA_Gains2_v7(observer);
    else
      RA_Loss2_v7(observer);
    end
  end
else
  % Something odd happened?
  error(['The sum of recorded blocks is uneven. Manual investigation ', ...
    'of data collection status required.']);
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
numBlocksPartial = length(choiceData) / trialsPerBlock;
numBlocks = round(numBlocksPartial);
if numBlocks ~= numBlocksPartial
  warning('Careful: %d trials in a block, but %d choices recorded.', ...
    trialsPerBlock, length(choiceData));
end
end
