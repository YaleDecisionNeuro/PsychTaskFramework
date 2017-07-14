classdef blockGenerationTest < matlab.unittest.TestCase
  properties
    TrialInput
    TestConfig
  end
    methods(TestClassSetup)
      function trialProperties(testCase)
        testCase.TrialInput = struct2table(struct('stakes', 2, ...
          'probs', NaN, 'ambigs', 0, 'stakes_loss', 1, 'reference', 2, ...
          'colors', NaN, 'ITIs', 5));
        testCase.TestConfig = configDefaults();
        testCase.TestConfig.trial.generate = struct(...
          'stakes', 2, ...
          'stakes_loss', 1, ...
          'probs', 0.5, ...
          'ambigs', [], ...
          'colors', 2);
        testCase.TestConfig.task.blockLength = 1;
      end
    end
%   methods(TestMethodTeardown)
%     function closeFigure(testCase)
%     end
%   end
  methods (Test)
    % TODO: generate all combinations of these columns but not the others
    % Missing values in catch trials filled correctly
    function fillInAmbiguity(testCase)
      actual = generateBlocks(testCase.TestConfig)
      expected = struct2table(struct('stakes', 2, 'probs', 0.5, ...
        'ambigs', 0, 'stakes_loss', 1, ...
        'colors', 2));
      testCase.verifyEqual(actual{1}, expected);
      % Would actually expect a block with the full config - I'm not sure
      % why that's not happening if the config is being passed in at this
      % point?
    end
    function generateBlocksFillsInEverything(testCase)
      
    end
  end
end

