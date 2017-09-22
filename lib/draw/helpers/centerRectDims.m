function dims = centerRectDims(center, rectSize, pxOffCenter)
% Finds center of screen and centers objects.
%
% A helper function to calculate what the top-left pixel of an object is such
% that the object will appear centered. Accepts `center` that defines [x y] of
% the screen's center, `rectSize` that defines the object's dimensions, and
% (non-obligatory) `pxOffCenter`, which shifts the resulting position.
%
% If pxOffCenter is supplied, shifts the computation by that much in both
% dimensions.
%
% Args:
%   center: The 2x1 coordinates of (a screen's) center 
%   rectSize: The 2x1 dimensions of a rectangle (screen)
%   pxOffCenter: A simple integer value by which the result should be adjusted
%     in both dimensions.
%
% Returns:
%   The 2x2 rectangular matrix of xy-coordinates usable as argument for
%   `PTB::Screen` functions.

  dims = [center - rectSize/2, center + rectSize/2];
  if exist('pxOffCenter', 'var')
    % FIXME: Test if `pxOffCenter` is a 1x1 or 2x1 matrix
    dims = dims + [pxOffCenter, pxOffCenter];
  end
end
