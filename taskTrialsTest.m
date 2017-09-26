classdef taskTrialsTest < matlab.unittest.TestCase
  % For simplicity, generating just one condition for each task
  methods (TestClassSetup)
    function loadFilepaths(testCase)
      addpath(genpath('tasks/'));
    end
  end
  methods (Test)
    function testRA(testCase)
      % verified to work on `master`
      gainConfig = RA_blockDefaults();
      gainBlocks = generateBlocks(gainConfig, gainConfig.trial.generate.catchTrial, ...
        gainConfig.trial.generate.catchIdx);

      testCase.verifyEqual(length(gainBlocks), 4);
      testCase.verifyEqual(cellfun(@height, gainBlocks), [31 31 31 31]');
    end
    function testMDM(testCase)
      medConfig = MDM_medicalConfig(MDM_blockDefaults());

      % 1. Generate 1 repeat of reference level trials, all possible P/A values
      tempLevels = medConfig.trial.generate;
      tempLevels.stakes = tempLevels.reference;
      tempLevels.repeats = 1;
      fillTrials = generateTrials(tempLevels);
      % fillTrials = fillTrials(randperm(height(fillTrials), 4), :)

      % 2. Generate 2 additional trials with reference payoff
      tempLevels = medConfig.trial.generate;
      tempLevels.stakes = tempLevels.reference;
      tempLevels.probs = 0.25;
      tempLevels.ambigs = 0.5;
      tempLevels.repeats = 1;
      fillTrials = [fillTrials; generateTrials(tempLevels)];
      % fillTrials = fillTrials(randperm(height(fillTrials), 2), :)

      % 3. Have generateBlocks create the standard number of repeats with
      %    non-reference values
      tempMedConfig = medConfig;
      tempMedConfig.trial.generate.stakes = medConfig.trial.generate.stakes(2:end);
      medBlocks = generateBlocks(tempMedConfig, medConfig.trial.generate.catchTrial, ...
        medConfig.trial.generate.catchIdx, fillTrials);

      testCase.verifyEqual(length(medBlocks), 4);
      testCase.verifyEqual(cellfun(@height, medBlocks), [21 21 21 21]');
    end
    function testSODM(testCase)
      config = SODM_blockDefaults();
      medConfig = SODM_medicalConfig(config);
      medSelfBlocks = generateBlocks(medConfig, medConfig.trial.generate.catchTrial, ...
        medConfig.trial.generate.catchIdx);
      testCase.verifyEqual(length(medSelfBlocks), 2);
      testCase.verifyEqual(cellfun(@height, medSelfBlocks), [19 19]');
    end
    function testUVRA(testCase)
      config = UVRA_blockDefaults();
      blocks = generateBlocks(config);
      testCase.verifyEqual(length(blocks), 6);
      testCase.verifyEqual(cellfun(@height, blocks), [20 20 20 20 20 20]');
    end
    function testHLFF(testCase)
      configMon = HLFF_monetaryConfig(HLFF_blockDefaults());
      blocksMon = generateBlocks(configMon, ...
        configMon.trial.generate.catchTrial, configMon.trial.generate.catchIdx);
      testCase.verifyEqual(length(blocksMon), 2);
      testCase.verifyEqual(cellfun(@height, blocksMon), [20 20]');
    end
  end
end
