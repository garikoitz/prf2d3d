
%{
TODO august 24 2023
   OK: add 3 circles: radius 3/3 8, 2/3 8, 1/3 8
   OK: align text to 3D plot
run number of vox:
    -- rught now we are using decimation_factor=10
    -- we want to have in 2D the same amount that we have in 3D, per every subject
re-run all 4 plots with the new drawing shit
%}



%%
clear all; close all; clc;

% an = '2d3d';
% an = '2d3dmodel';
% an = 'number_vox'; % simulate the data directly asigning gaussian, few/lots
% an = 'hrlr';
% an = 'upsample'; % upsample voxels from 2iso to 1iso to see if goes foveal due to the curve

an_types = {'2d3d','2d3dmodel','number_vox2d2d','number_vox2d3d','upsample'};
an_types = {'number_vox2d3d'};
an_types = {'sensotive_blind', 'sensotive_sight', 'votcloc_bhd2pilots', 'sight_blind'};
an_types = {'heb-2d', 'heb-3d'};

%{

p001: David-BCBL
    S001: sight
    S002: blind
p002: Sandra-BCBL
    S001: blind
    S002: sight
p003: Leandro-BCBL
    S001: blind
    S002: sight
p004: Abraham-BCBL
    S001: blind >>> DOES NOT EXIST, DATA WAS OVERWRITE
    S002: sight


Other data in the SENSOTIVE/dicom folder:

bt001: Gari-BCBL: testing, do not use
bt002: Leandro-BCBL: testing, do not use
p001nn: David-BCBL (NO NORDIC): same as p001, but no nordic correction for analyses
t001: David-Vienna (sequence different, maybe stimuli the same)


%}
recalculate = false;

% Rosemary's code to obtain the eccentricity plots
list_roiNames = {'WangAtlas_V1d_left'
                 'WangAtlas_V2d_left'
                 'WangAtlas_V3d_left'
                 'WangAtlas_V1v_left'
                 'WangAtlas_V2v_left'
                 'WangAtlas_V3v_left'
                 'WangAtlas_hV4_left'
                 'WangAtlas_VO1_left'
                 'WangAtlas_V3A_left'
                 'WangAtlas_IPS0_left'
                 'WangAtlas_IPS1_left'
                 'WangAtlas_V1d_right'
                 'WangAtlas_V2d_right'
                 'WangAtlas_V3d_right'
                 'WangAtlas_V1v_right'
                 'WangAtlas_V2v_right'
                 'WangAtlas_V3v_right'
                 'WangAtlas_hV4_right'
                 'WangAtlas_VO1_right'
                 'WangAtlas_V3A_right'
                 'WangAtlas_IPS0_right'
                 'WangAtlas_IPS1_right'};

list_dtNames  = {'Checkers','Words'};
list_dtNames  = {'WordSight','WordBlind'};
list_dtNames  = {'English','Hebrew','Checkers'};
list_rmNames  = list_dtNames;
% Read the generic params for coverage for all subjects
cr.defaults.covfig.vfc = ff_vfcDefault();
cr.defaults.covfig.vfc.list_roiNames = list_roiNames;
% data types we want to look at
cr.defaults.covfig.vfc.list_dtNames = list_dtNames;
% names of the rm in each dt
cr.defaults.covfig.vfc.list_rmNames = list_rmNames;


varexp = 0.05;
list_dtNames  = {'English','Hebrew','Checkers'};
titlestring       = 'WHvsCB';
data_select =[3,2];

for na=1:length(an_types)
    an = an_types{na}

    
    cr         = struct();
    cr.codeDir = prf2d3dRP;
    cr.dirs.DATA     = fullfile(cr.codeDir,'DATA');
    cr.dirs.ORG      = fullfile(cr.codeDir,'DATA','ANALYSIS','matlabfiles','organization');
    cr.dirs.DEF      = fullfile(cr.codeDir,'DATA','ANALYSIS','matlabfiles','defineProjectDefaults');
    cr.dirs.FIG     = fullfile(cr.dirs.DATA,'FIGURES','HEB');
    cr.dirs.FIGPNG  = fullfile(cr.dirs.FIG,'png');
    cr.dirs.FIGSVG  = fullfile(cr.dirs.FIG,'svg');
    cr.bk = bookKeeping(cr);
    
    switch an
        case 'heb-2d'
            % Prepare data and defaults
            load(fullfile(prf2d3dRP,'DATA','mats', ...
                'rmroicell_HEB_An-01-2D_prfpreparev01.mat'));
            
            list_subInds      = 1:size(rmroiCell,1);
            % after seeing indiv plots removed 25 and 26
            % list_subInds      = [1:24,27:28]; 
            list_roiNames = {'WangAtlas_V1d_left'
                 'WangAtlas_V2d_left'
                 'WangAtlas_V3d_left'
                 'WangAtlas_V1v_left'
                 'WangAtlas_V2v_left'
                 'WangAtlas_V3v_left'
                 'WangAtlas_hV4_left'
                 'WangAtlas_VO1_left'
                 'WangAtlas_V3A_left'
                 'WangAtlas_IPS0_left'
                 'WangAtlas_IPS1_left'
                 'WangAtlas_V1d_right'
                 'WangAtlas_V2d_right'
                 'WangAtlas_V3d_right'
                 'WangAtlas_V1v_right'
                 'WangAtlas_V2v_right'
                 'WangAtlas_V3v_right'
                 'WangAtlas_hV4_right'
                 'WangAtlas_VO1_right'
                 'WangAtlas_V3A_right'
                 'WangAtlas_IPS0_right'
                 'WangAtlas_IPS1_right'};
            
            list_rmNames  = list_dtNames;
            list_rmDescripts  = list_dtNames;

            
            fnamestring       = titlestring;
            zlimbyan          = [-1,2];


            % 
            roi_ind = [4:8, 9:11];
            rmroiCell_WC     = rmroiCell(:,roi_ind,data_select);
            % rmroiCell_WC     = flip(rmroiCell_WC,3);
            list_roiNames16  = list_roiNames(roi_ind);
            % list_rmDescripts = {'WordsSighted', 'WordBlind'};
            % list_rmDescripts = {'CheckersSighted', 'CheckersBlind'};
            list_rmDescripts16 = list_rmDescripts(flip(data_select));
            % list_subInds = 2:3;
            
            % Obtain equally thresholded voxels to scatterplot
            [R,C_data,cr]=crThreshGetSameVoxel(cr,...
                                               rmroiCell_WC,...
                                               list_subInds,...
                                               list_roiNames16,...
                                               'cothres', varexp,...
                                               'fieldrange', 7);
            
            % Plot it
            fontsize = 12;
            fname = ['LEFT_scatterplot_eccentricity_' an '_' titlestring '_varexp-' num2str(varexp)];
            [percAboveIdentity] = crCreateScatterplot(R,C_data,cr,...
                                                list_subInds,...
                                                strrep(strrep(list_roiNames16,'WangAtlas_',''),'_','\_'),...
                                                list_rmDescripts16,...
                                                'ecc', ...  % 'co'
                                                fontsize, ...
                                                fname, ...
                                                5); % cutoff, in deg




        case 'heb-3d'
            % Prepare data and defaults
            load(fullfile(prf2d3dRP,'DATA','mats', ...
                'rmroicell_HEB_An-02-3D_prfpreparev01.mat'));
            
            list_subInds      = 1:size(rmroiCell,1);
            % after seeing indiv plots removed 25 and 26
            % list_subInds      = [1:24,27:28]; 
            list_roiNames = {'WangAtlas_V1d_left'
                 'WangAtlas_V2d_left'
                 'WangAtlas_V3d_left'
                 'WangAtlas_V1v_left'
                 'WangAtlas_V2v_left'
                 'WangAtlas_V3v_left'
                 'WangAtlas_hV4_left'
                 'WangAtlas_VO1_left'
                 'WangAtlas_V3A_left'
                 'WangAtlas_IPS0_left'
                 'WangAtlas_IPS1_left'
                 'WangAtlas_V1d_right'
                 'WangAtlas_V2d_right'
                 'WangAtlas_V3d_right'
                 'WangAtlas_V1v_right'
                 'WangAtlas_V2v_right'
                 'WangAtlas_V3v_right'
                 'WangAtlas_hV4_right'
                 'WangAtlas_VO1_right'
                 'WangAtlas_V3A_right'
                 'WangAtlas_IPS0_right'
                 'WangAtlas_IPS1_right'};
            list_rmNames  = list_dtNames;
            list_rmDescripts  = list_dtNames;
            
            

            fnamestring       = titlestring;
            zlimbyan          = [-1,2];

            % 
            roi_ind = [4:8, 9:11];
            rmroiCell_WC     = rmroiCell(:,roi_ind,data_select);
            % rmroiCell_WC     = flip(rmroiCell_WC,3);
            list_roiNames16  = list_roiNames(roi_ind);
            % list_rmDescripts = {'WordsSighted', 'WordBlind'};
            % list_rmDescripts = {'CheckersSighted', 'CheckersBlind'};
            list_rmDescripts16 = list_rmDescripts(flip(data_select));
            % list_subInds = 2:3;
            
            % Obtain equally thresholded voxels to scatterplot
            [R,C_data,cr]=crThreshGetSameVoxel(cr,...
                                               rmroiCell_WC,...
                                               list_subInds,...
                                               list_roiNames16,...
                                               'cothres', varexp,...
                                               'fieldrange', 7);
            
            % Plot it
            fontsize = 12;
            fname = ['LEFT_scatterplot_eccentricity_' an '_' titlestring '_varexp-' num2str(varexp)];
            [percAboveIdentity] = crCreateScatterplot(R,C_data,cr,...
                                                list_subInds,...
                                                strrep(strrep(list_roiNames16,'WangAtlas_',''),'_','\_'),...
                                                list_rmDescripts16,...
                                                'ecc', ...  % 'co'
                                                fontsize, ...
                                                fname, ...
                                                5); % cutoff, in deg


    
        otherwise
            error('Analysis case not defined')
    end

end


