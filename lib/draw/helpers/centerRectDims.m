function dims = centerRectDims(center, rectSize, pxOffCenter)
% Finds center of screen and centers objects.
%
% A helper function to calculate what the top-left pixel of
%   an object is such that the object will appear centered. Accepts `center`
%   that defines [x y] of the screen's center, `rectSize` that defines the
%   object's dimensions, and (non-obligatory) `pxOffCenter`, which shifts
%   the resulting position.
%
% Args:
%   center: The coordinates of (a screen's) center 
%   rectSize: The dimensions of a rectangle (screen)
%   pxOffCenter: Calculates when object is not centered
%
% Returns:
%   dims: The dimensions needed to center an object

  dims = [center - rectSize/2, center + rectSize/2];
  if exist('pxOffCenter', 'var')
    % FIXME: Test if `pxOffCenter` is a 1x1 or 2x1 matrix
    dims = dims + [pxOffCenter, pxOffCenter];
  end
end
