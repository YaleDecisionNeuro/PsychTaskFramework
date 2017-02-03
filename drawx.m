function [ Data ] = drawX(Data, settings, callback)
% This is suggested pattern of what drawX functions should look like.
%
% Typically, draw function will draw one scene. The body of the main
% function handles that, based on deviceSettings and elementSettings.
%
% Optionally, the function wait for the user to respond, record their
% response and/or reaction time, and draw whatever it should in response
% before handing off execution up the stack.
%
% It is suggested that the wait, timing and recording be abstracted out
% of the draw logic into either a callback function passed as an argument,
% or a local function defined underneath this one.
%
% While nothing is stopping the callback / secondary function from defining
% further draw logic, separating this responsibility into a different draw
% function is a sustainable way to write code.

%%
%% Draw logic here
%%

if exist('callback', 'var') && isHandle(callback)
  Data = callback(Data, settings);
end
end

% Sample local function with timing responsibility
function Data = timeX(Data, settings)

end

% Sample local function with data-recording responsibility
function Data = recordX(Data, settings)

end
