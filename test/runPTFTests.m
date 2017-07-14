function [ result ] = runPTFTests()
  import matlab.unittest.TestSuite
  addpath(genpath('./test/unit'));

  unitTests = TestSuite.fromFolder('./test/unit');
  result = run(unitTests);
end