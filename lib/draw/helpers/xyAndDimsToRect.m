function rect = xyAndDimsToRect(xy, dims)
% Given origin point and dimensions, returns the rect matrix for Screen.
%
% Converts a top-left xy-coordinate and a 2x1 widthxlength matrix to 2x2
% dimensions expected by PsychToolBox's Screen.
%
% Args:
%   xy: The coordinate top-left origin of an object
%   dims: The dimensions (height and width) of an object
%
% Returns:
%   rect: A rectangle usable by Screen
  rect = [xy(1), xy(2), xy(1) + dims(1), xy(2) + dims(2)];
end
