
function rect = xyAndDimsToRect(xy, dims)
% Specifies coordinates and dimensions of a rectangle (screen)
%
% Args:
%   xy: The coordinate points of an object
%   dims: The dimensions (height and width) of an object
%
% Returns:
%   rect: A rectangle of known dimensions and coordinates
  rect = [xy(1), xy(2), xy(1) + dims(1), xy(2) + dims(2)];
end
