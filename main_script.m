list_subInds  = [1:28];
list_roiNames = {'V1','V2','V3'};
list_dtNames  = {'01','02'}; % 01 is 2D, 02 is 3D

cr         = struct();
cr.codeDir = prf2d3dRP;
cr.dirs.DATA     = fullfile(cr.codeDir,'DATA');
cr.dirs.ORG      = fullfile(cr.codeDir,'DATA','ANALYSIS','matlabfiles','organization');
cr.dirs.DEF      = fullfile(cr.codeDir,'DATA','ANALYSIS','matlabfiles','defineProjectDefaults');
cr.bk = bookKeeping(cr);

% PRepare data and defaults
load(fullfile(prf2d3dRP,'DATA','rmroicellOHBM.mat'))
list_roiNames     = {'V1','V2','V3'};
list_rmDescripts  = {'2D','3D'};
list_dtNames      = {'2D','3D'};
list_rmNames      = {'2D','3D'};

% Read the generic params for coverage for all subjects
cr.defaults.covfig.vfc = ff_vfcDefault();
cr.defaults.covfig.vfc.list_roiNames = list_roiNames;
% data types we want to look at
cr.defaults.covfig.vfc.list_dtNames = list_dtNames;
% names of the rm in each dt
cr.defaults.covfig.vfc.list_rmNames = list_rmNames;



% Launch the function
% fname = 'CoverageBoot_';%'Fig1_'; % '' for not saving
fname = ''; % 
[RF_mean, RF_individuals, empties] = figFunction_coverage_maxProfile_group(...
                                      cr,list_subInds, ...
                                      'flip',false, ...
                                      'bootcontour', false, ...
                                      'rmroiCell',rmroiCell, ...
                                      'list_roiNames', list_roiNames, ...
                                      'list_dtNames', list_dtNames, ...
                                      'list_rmNames', list_rmNames, ...
                                      'sizedegs',8,...
                                      'minvarexp', 0.1, ...
                                      'numboots', 25, ...
                                      'fname', fname, ...
                                      'vers',['v01'],...
                                      'invisible',false);