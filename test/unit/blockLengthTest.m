classdef blockLengthTest < matlab.unittest.TestCase
  properties
    TrialNumber
    TestConfig
  end
    methods(TestClassSetup)
      function trialProperties(testCase)
        testCase.TrialNumber = 20;
        testCase.TestConfig.task = struct;
        testCase.TestConfig.task.numBlocks = 1;
        testCase.TestConfig.task.blocksPerSession = 1;
        % testCase.TestConfig.task.blockLength = 1;
      end
    end
  methods (Test)
    % 1. Basic generation with numBlocks only
    function numBlocksOnly(testCase)
      % one block
      actual = getBlockLengths(testCase.TestConfig, testCase.TrialNumber);
      expected = [20];
      testCase.verifyEqual(actual, expected);

      % two blocks
      testCase.TestConfig.task.numBlocks = 2;
      actual = getBlockLengths(testCase.TestConfig, testCase.TrialNumber);
      expected = [10; 10];
      testCase.verifyEqual(actual, expected);
    end
    % 2. Basic generation with blockLength only
    function blockLengthOnly(testCase)
      % one block
      testCase.TestConfig.task = rmfield(testCase.TestConfig.task, 'numBlocks');
      testCase.TestConfig.task.blockLength = 20;
      actual = getBlockLengths(testCase.TestConfig, testCase.TrialNumber);
      expected = [20];
      testCase.verifyEqual(actual, expected);

      % two blocks
      testCase.TestConfig.task.blockLength = 10;
      actual = getBlockLengths(testCase.TestConfig, testCase.TrialNumber);
      expected = [10; 10];
      testCase.verifyEqual(actual, expected);
    end

    % 3. Non-zero catch trial count
    % 3a. If numBlocks is set, the argument doesn't change anything
    function numBlocksTrumpsCatchTrials(testCase)
      actual = getBlockLengths(testCase.TestConfig, testCase.TrialNumber, 2);
      expected = [20];
      testCase.verifyEqual(actual, expected);
    end

    % 3b. If numBlocks is not set but blockLength is & includes catch trials,
    %     returned block lengths subtract numCatchTrials
    function blockLengthIncludesCatchTrials(testCase)
      testCase.TestConfig.task = rmfield(testCase.TestConfig.task, 'numBlocks');
      testCase.TestConfig.task.blockLength = 12;
      actual = getBlockLengths(testCase.TestConfig, testCase.TrialNumber, 2);
      expected = [10; 10];
      testCase.verifyEqual(actual, expected);
    end

    %% Corner cases that raise warnings - things that aren't divisible
    % numBlocks trumps blockLength but raises a warning
    function numBlocksTrumpsBlockLength(testCase)
      testCase.TestConfig.task.numBlocks = 2;
      testCase.TestConfig.task.blockLength = 20;
      % actual = getBlockLengths(testCase.TestConfig, testCase.TrialNumber);
      expected = [10; 10];
      actual = testCase.verifyWarning(@() ...
        getBlockLengths(testCase.TestConfig, testCase.TrialNumber), ...
        'PTF:getBlockLengths:configBlockLengthInconsistency');
      testCase.verifyEqual(actual, expected);
    end

    % numBlocks is heeded but trials are redistributed
    function redistributeLeftoversForNumBlocks(testCase)
      testCase.TestConfig.task.numBlocks = 3;
      expected = [7; 7; 6];
      actual = testCase.verifyWarning(@() ...
        getBlockLengths(testCase.TestConfig, testCase.TrialNumber), ...
        'PTF:getBlockLengths:unevenBlockLengths');
      testCase.verifyEqual(actual, expected);
    end

    % blockLength wins, adds block with leftover trials
    function addBlockForNumBlocks(testCase)
      testCase.TestConfig.task.numBlocks = false;
      testCase.TestConfig.task.numSessions = false;
      testCase.TestConfig.task.numBlocksPerSession = false;
      testCase.TestConfig.task.blockLength = 6;
      expected = [6; 6; 6; 2];
      actual = testCase.verifyWarning(@() ...
        getBlockLengths(testCase.TestConfig, testCase.TrialNumber), ...
        'PTF:getBlockLengths:extraBlockNeeded');
      testCase.verifyEqual(actual, expected);
    end

    %% 4. Function intelligently fills in from other settings
    function fillInNumBlocksFromOtherSettings(testCase)
      testCase.TestConfig.task.numBlocks = false;
      testCase.TestConfig.task.blocksPerSession = 4;
      testCase.TestConfig.task.blockLength = false;
      actual = getBlockLengths(testCase.TestConfig, testCase.TrialNumber);
      expected = [5; 5; 5; 5];
      testCase.verifyEqual(actual, expected);
    end
  end
end
