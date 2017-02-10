function dims = centerRectDims(center, rectSize, pxOffCenter)
% CENTERRECTDIMS A helper function to calculate what the top-left pixel of
%   an object is such that the object will appear centered. Accepts `center`
%   that defines [x y] of the screen's center, `rectSize` that defines the
%   object's dimensions, and (non-obligatory) `pxOffCenter`, which shifts
%   the resulting position.

  dims = [center - rectSize/2, center + rectSize/2];
  if exist('pxOffCenter', 'var')
    % FIXME: Test if `pxOffCenter` is a 1x1 or 2x1 matrix
    dims = dims + [pxOffCenter, pxOffCenter];
  end
end
