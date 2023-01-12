function rootPath=prf2d3dRP()
%
%        rootPath =mrvRootPath;
%
% Determine path to root of the coverageReading directory
%
% This function MUST reside in the directory at the base of the
% coverageReading directory structure
%
% Wandell

rootPath=which('prf2d3dRP');

[rootPath,fName,ext]=fileparts(rootPath);

return
