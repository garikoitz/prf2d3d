
% TODO meeting 9th: (1) paste figures and discuss layout, (2) discuss how to visualize and compare time series to explain the results

%%
clear all; close all;



cr         = struct();
cr.codeDir = prf2d3dRP;
cr.dirs.DATA     = fullfile(cr.codeDir,'DATA');
cr.dirs.ORG      = fullfile(cr.codeDir,'DATA','ANALYSIS','matlabfiles','organization');
cr.dirs.DEF      = fullfile(cr.codeDir,'DATA','ANALYSIS','matlabfiles','defineProjectDefaults');
cr.dirs.FIG     = fullfile(cr.dirs.DATA,'FIGURES');
cr.dirs.FIGPNG  = fullfile(cr.dirs.FIG,'png');
cr.dirs.FIGSVG  = fullfile(cr.dirs.FIG,'svg');
cr.bk = bookKeeping(cr);

% Prepare data and defaults
load(fullfile(prf2d3dRP,'DATA','rmroicellOHBM.mat'))

list_subInds      = 1:28;
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



%% Launch the function
% fname = 'CoverageBoot_varexp02_';%'Fig1_'; % '' for not saving
fname = ''; % 
[RF_mean, RF_individuals, empties] = figFunction_coverage_maxProfile_group(...
                                      cr,list_subInds, ...
                                      'flip',false, ...
                                      'bootcontour', false, ...
                                      'rmroiCell',rmroiCell, ...
                                      'list_roiNames', list_roiNames, ...
                                      'list_dtNames', list_dtNames, ...
                                      'list_rmNames', list_rmNames, ...
                                      'sizedegs', 8,...
                                      'minvarexp', 0.2, ...
                                      'numboots', 10, ...
                                      'fname', fname, ...
                                      'vers','v01',...
                                      'method', 'avg', ...
                                      'density', false, ... 
                                      'invisible',true);



%% PLOT THEM FOR V1, DO BOOTSTRAPPING AND AVERAGE IT
for nr=1:3
    ALL2d=RF_individuals{nr,1};
    ALL3d=RF_individuals{nr,2};
    
    MVALS = zeros(128,128,50);
    SVALS = zeros(128,128,50);
    DVALS = zeros(128,128,50);
    
    for kk=1:50
        % Remove 1 each time and create same plots with the remaining one
        nsubsminus1 = size(ALL2d,3)-1;
        randReplacement = datasample(1:nsubsminus1,nsubsminus1);
        all2d           = ALL2d(:,:,randReplacement);
        all3d           = ALL3d(:,:,randReplacement);
        
        % Calculate measures
        mval   = mean(all2d - all3d, 3);
        stdval = std(all2d - all3d, [],3);
        Cd     = zeros(128,128);
        for ii=1:128;for jj=1:128
                Cd(ii,jj)=computeCohen_d(all2d(ii,jj,:),all3d(ii,jj,:),'paired');
        end;end
    
        % Accummlate it
        MVALS(:,:,kk) = mval;
        SVALS(:,:,kk) = stdval;
        DVALS(:,:,kk) = Cd;
        
    end   
    
    % obtain means again
    mval   = mean(MVALS,3);
    stdval = mean(SVALS,3);
    Cd     = mean(DVALS,3);
    
    
    % PLOT
    xdeg = 8; ydeg = 8;
    mrvNewGraphWin('bootstraps2d3dFOV','wide',true);
    subplot(1,2,1)
    imagesc(Cd);axis equal;colormap(parula);colorbar;grid
    title("d': mean 50 bootstraps [2D-3D]")
    xlim([1,128]);ylim([1,128])
    xticks([1,64,128]); yticks([1,64,128])
    % caxis([-1.25,1.25])
    caxis([-1,2])
    xticklabels([-xdeg,0,xdeg]); yticklabels([-ydeg,0,ydeg])
    xlabel('Degs'); ylabel('Degs')
    
    % subplot(1,2,2)
    subplot(1,2,2)
    [X,Y] = meshgrid(1:128,1:128);
    XX = ((X-64)/64)*xdeg;
    YY = ((Y-64)/64)*ydeg;
    YY = flipud(YY);
    surf(XX,YY,Cd);
    xlabel('X (degs)'); ylabel('Y (degs)')
    zlabel("Cohen's d")
    xlim([-xdeg,xdeg])
    ylim([-ydeg,ydeg])
    zlim([-1,2])
    xticks([-8,-4,0,4,8])
    yticks([-8,-4,0,4,8])
    xticklabels({'-8','-4','0','4','8'})
    yticklabels({''})
    set(gca,'FontSize',18)
    
    fname = ['FOV_Comparisons_ROI-' list_roiNames{nr} '_2dvs3d_vfc.method_avg_varexp02'];
    set(0, 'DefaultFigureRenderer', 'painters');
    saveas(gcf, fullfile(cr.dirs.FIGPNG, [fname '.png']), 'png')
    saveas(gcf, fullfile(cr.dirs.FIGSVG,[fname '.svg']), 'svg')
end
%% Individual plots
for nr=1:3
    ALL2d=RF_individuals{nr,1};
    ALL3d=RF_individuals{nr,2};

    mrvNewGraphWin('CrossVal2dvs3dFOV');
    ha = tight_subplot(4,size(ALL3d,3)/4,[.03 .03],[.1 .01],[.01 .01]);
    subnames = 1:size(ALL3d,3);
    ve = 0.25;
    for nn=1:size(ALL2d,3)
        all2d = ALL2d(:,:,nn);
        all3d = ALL3d(:,:,nn);
        axes(ha(nn));
        imagesc(all2d-all3d);axis equal;colormap(jet);colorbar;grid
        caxis([-.1,.1])
        % title(sprintf('Sub ind %i',nn))
        title(['ROI-' list_roiNames{nr} '_sub-' num2str(subnames(nn))])
        xlim([1,128]);ylim([1,128])
        xticks([1,64,128]); yticks([1,64,128])
        xticklabels([-xdeg,0,xdeg]); yticklabels([-ydeg,0,ydeg])
    
    end
    
    ha    = xlabel('Degs');
    ha(1) = ylabel('Degs');
    titlefile  = ['IndividualSubject2d-3d_ROI-' list_roiNames{nr} ...
        '_N-' num2str(size(ALL2d,3)) '_VE-' num2str(100*ve) ];
    saveas(gcf, fullfile(cr.dirs.FIGPNG,[titlefile '.png']), 'png')
    saveas(gcf, fullfile(cr.dirs.FIGSVG,[titlefile '.svg']), 'svg')
end
close all


%% After seing the individuals, remove 25 and 26 and create group analyses
%% Launch the function
% fname = 'CoverageBoot_varexp02_';%'Fig1_'; % '' for not saving
list_subInds_no2526      = [1:24,27:28];

for nr=1:3
    ALL2d=RF_individuals{nr,1};
    ALL3d=RF_individuals{nr,2};
    
    ALL2d = ALL2d(:,:,list_subInds_no2526);
    ALL3d = ALL3d(:,:,list_subInds_no2526);


    MVALS = zeros(128,128,50);
    SVALS = zeros(128,128,50);
    DVALS = zeros(128,128,50);
    
    for kk=1:50
        % Remove 1 each time and create same plots with the remaining one
        nsubsminus1 = size(ALL2d,3)-1;
        randReplacement = datasample(1:nsubsminus1,nsubsminus1);
        all2d           = ALL2d(:,:,randReplacement);
        all3d           = ALL3d(:,:,randReplacement);
        
        % Calculate measures
        mval   = mean(all2d - all3d, 3);
        stdval = std(all2d - all3d, [],3);
        Cd     = zeros(128,128);
        for ii=1:128;for jj=1:128
                Cd(ii,jj)=computeCohen_d(all2d(ii,jj,:),all3d(ii,jj,:),'paired');
        end;end
    
        % Accummlate it
        MVALS(:,:,kk) = mval;
        SVALS(:,:,kk) = stdval;
        DVALS(:,:,kk) = Cd;
        
    end   
    
    % obtain means again
    mval   = mean(MVALS,3);
    stdval = mean(SVALS,3);
    Cd     = mean(DVALS,3);
    
    
    % PLOT
    xdeg = 8; ydeg = 8;
    mrvNewGraphWin('bootstraps2d3dFOV','wide',true);
    subplot(1,2,1)
    imagesc(Cd);axis equal;colormap(parula);colorbar;grid
    title("d': mean 50 bootstraps [2D-3D]")
    xlim([1,128]);ylim([1,128])
    xticks([1,64,128]); yticks([1,64,128])
    % caxis([-1.25,1.25])
    caxis([-1,2])
    xticklabels([-xdeg,0,xdeg]); yticklabels([-ydeg,0,ydeg])
    xlabel('Degs'); ylabel('Degs')
    
    % subplot(1,2,2)
    subplot(1,2,2)
    [X,Y] = meshgrid(1:128,1:128);
    XX = ((X-64)/64)*xdeg;
    YY = ((Y-64)/64)*ydeg;
    YY = flipud(YY);
    surf(XX,YY,Cd);
    xlabel('X (degs)'); ylabel('Y (degs)')
    zlabel("Cohen's d")
    xlim([-xdeg,xdeg])
    ylim([-ydeg,ydeg])
    zlim([-1,2])
    xticks([-8,-4,0,4,8])
    yticks([-8,-4,0,4,8])
    xticklabels({'-8','-4','0','4','8'})
    yticklabels({''})
    set(gca,'FontSize',18)
    
    fname = ['FOV_Comparisons_ROI-' list_roiNames{nr} '_2dvs3d_vfc.method_avg_varexp02_NO-25-26'];
    set(0, 'DefaultFigureRenderer', 'painters');
    saveas(gcf, fullfile(cr.dirs.FIGPNG, [fname '.png']), 'png')
    saveas(gcf, fullfile(cr.dirs.FIGSVG,[fname '.svg']), 'svg')
end




