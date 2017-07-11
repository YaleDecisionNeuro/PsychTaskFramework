function [ isLegacy ] = isLegacyDataObject( DataObject )
% Based on its fields, determine if DataObject uses pre-v1.0.1-beta format.
%
% Checks for observer field and whether the blocks field is a struct. If
% there is no observer field, subjectId field exists, and the blocks field
% is a cell array, the object is identified as the current specification.
%
% :param DataObject: a per-subject struct created by loadOrCreate
% :returns: True if the data was collected prior to v1.0.1-beta, false
% otherwise.
isLegacy = isfield(DataObject, 'observer') ...
    || isstruct(DataObject.blocks) ...
    || ~isfield(DataObject, 'subjectId');
end

