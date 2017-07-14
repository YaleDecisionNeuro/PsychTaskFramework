classdef trialGenerationTest < matlab.unittest.TestCase
  properties
    TrialValues
  end
    methods(TestClassSetup)
      function trialProperties(testCase)
        testCase.TrialValues = struct('stakes', 2, 'probs', NaN, ...
          'ambigs', [], 'stakes_loss', 1, 'reference', 2, ...
          'colors', NaN, 'ITIs', 5);
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
      actual = generateTrials(testCase.TrialValues);
      expected = struct2table(struct('stakes', 2, 'probs', NaN, ...
        'ambigs', 0, 'stakes_loss', 1, 'reference', 2, ...
        'colors', NaN, 'ITIs', 5));
      testCase.verifyEqual(actual, expected);
    end
    function generateMinimal(testCase)
      input = struct('stakes', 2);
      actual = generateTrials(input);
      expected = table;
      testCase.verifyEqual(actual, expected);
    end
  end
end

