function [ txt, txtDims ] = textLookup(keyIdx, lookupTable, windowPtr)
% Supplies the specified text and text dimensions.
%
% Given an index in `keyIdx`, returns the (presumed character array)
%   value corresponding to that index in `lookupTable` cell array. If provided
%   `windowPtr`, also returns the dimensions that the text would take up under
%   the current config in that PTB window.\
%
% Args:
%   keyIdx: A key index
%   lookupTable: A table containing indexed values
%   windownPtr: A window pointer to specify screen
%
% Returns:
%   2-element tuple containing
%
%   - **txt**: The characters displayed on a screen.
%   - **txtDims**: The dimensions of the displayed text.

  txt = lookupTable{keyIdx};
  if exist('windowPtr', 'var')
    txtDims = getTextDims(windowPtr, txt);
  end
end
