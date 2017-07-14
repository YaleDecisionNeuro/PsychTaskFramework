classdef dollarFormatterTest < matlab.unittest.TestCase
  methods (Test)
    function formatPositive(testCase)
      actual = dollarFormatter(20);
      expected = '$20';
      testCase.verifyEqual(actual, expected);
    end
    function formatNegative(testCase)
      actual = dollarFormatter(-20);
      expected = '-$20';
      testCase.verifyEqual(actual, expected);
    end
    function formatZero(testCase)
      actual = dollarFormatter(0);
      expected = '$0';
      testCase.verifyEqual(actual, expected);
    end
  end
end

