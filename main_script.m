
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
recalculate = false;

for na=1:length(an_types)
    an = an_types{na}

    
    cr         = struct();
    cr.codeDir = prf2d3dRP;
    cr.dirs.DATA     = fullfile(cr.codeDir,'DATA');
    cr.dirs.ORG      = fullfile(cr.codeDir,'DATA','ANALYSIS','matlabfiles','organization');
    cr.dirs.DEF      = fullfile(cr.codeDir,'DATA','ANALYSIS','matlabfiles','defineProjectDefaults');
    cr.dirs.FIG     = fullfile(cr.dirs.DATA,'FIGURES');
    cr.dirs.FIGPNG  = fullfile(cr.dirs.FIG,'png');
    cr.dirs.FIGSVG  = fullfile(cr.dirs.FIG,'svg');
    cr.bk = bookKeeping(cr);
    
    switch an
        case '2d3d'
            % Prepare data and defaults
            % load(fullfile(prf2d3dRP,'DATA','rmroicellOHBM.mat'))
            load(fullfile(prf2d3dRP,'DATA','rmroicell_mini_vol_surf_new.mat')) % This is in the abstract
            
            list_subInds      = 1:size(rmroiCell,1);
            % after seeing indiv plots removed 25 and 26
            % list_subInds      = [1:24,27:28]; 
            list_roiNames     = {'V1','V2','V3'};
            list_rmDescripts  = {'2D','3D'};
            list_dtNames      = {'2D','3D'};
            list_rmNames      = {'2D','3D'};
            titlestring       = '2D - 3D';
            fnamestring       = '2Dvs3D';
            zlimbyan          = [-1,2];
            varexp = 0.2;
    
    
        case '2d3dmodel'
            % Prepare data and defaults
            load(fullfile(prf2d3dRP,'DATA','rmroicell_mini_vol_surf_models.mat'))
            
    
            % Compare first differences in the results
            
            
            tmpData = rmroiCell{1, 1, 1};
            for nf=1:length(fieldnames(tmpData))
                fnames = fieldnames(tmpData);
                f = fnames{nf};
                switch f
                    case {'vt','session','name'}
                            a = 'do nothing';
                    otherwise
                        for nr=1:3
                            allData1 = rmroiCell{ns, nr, 1};
                            allData2 = rmroiCell{ns, nr, 2};
                            for ns=1:30
                                tmpData1 = rmroiCell{ns, nr, 1};
                                tmpData2 = rmroiCell{ns, nr, 1};
                                Nvertex = length(tmpData.x0);
                                Cd=computeCohen_d(tmpData1.(f), tmpData2.(f));
                                % fprintf('Subject %i, roi %i, meas %s, Cohens: %g \n', ns, nr, f, Cd)
                                % Sum all subject data
                                if ns > 1
                                    allData1.(f) = [allData1.(f),tmpData1.(f)];
                                    allData2.(f) = [allData2.(f),tmpData2.(f)];
                                end
                            end
                            % Do the Cohen's d and t stats
                            Cd=computeCohen_d(allData1.(f), allData2.(f));
                            [H,P]=ttest2(allData1.(f), allData2.(f));
                            fprintf('All subjects, param %s, roi %s, Cohen d\'': %g, ttest(p):%g \n', ...
                                     f,list_roiNames{nr}, Cd, P)
                        end
                end 
            end
    
    
            list_subInds      = 1:size(rmroiCell,1);
            % after seeing indiv plots removed 25 and 26
            % list_subInds      = [1:24,27:28]; 
            list_roiNames     = {'V1','V2','V3'};
            list_rmDescripts  = {'2D','3D'};
            list_dtNames      = {'2D','3D'};
            list_rmNames      = {'2D','3D'};
            titlestring       = '2D - 3D-model';
            fnamestring       = '2Dvs3D-model';
            zlimbyan          = [-1,6];
            varexp = 0.5;
    
        case 'number_vox2d2d'
            % Prepare data and defaults
            % now the data will not come from pRF fits. We will just generate
            % 2D gaussians randomly, and one group will have 10% of voxels
            % than the other one
            % 1st test: take just the modeled vertices, and take random 10%
            % 2nd test: do a proper randomization and create both datasets from
            % gaussians from scratch
            % TEST 1
            load(fullfile(prf2d3dRP,'DATA','rmroicell_mini_vol_surf_models.mat'))
            % second column is voxels, substitute by a subset of vertices in
            % the first column
            % substitute for by funs...
            % decimation_factor = 10;
            rng(12345, 'twister')
            rmroiCellSIM = rmroiCell;
            for ns=1:30; for nr=1:3
                tmpData = rmroiCell{ns, nr, 1};
                tmpData2 = rmroiCell{ns, nr, 2};
                Nvertex = length(tmpData.x0);
                Nvertex2 = length(tmpData2.x0);
                rndInd = randi([1,Nvertex],[Nvertex2,1]);
                for nf=1:length(fieldnames(tmpData))
                    fnames = fieldnames(tmpData);
                    f = fnames{nf};
                    switch f
                        case {'vt','session','name'}
                            % disp(f)
                            continue
                        otherwise
                            ttd = tmpData.(f);
                            tmpData.(f) = ttd(rndInd);
                    end
                end
                rmroiCellSIM{ns, nr, 2} = tmpData;
            end;end
    
    
            rmroiCell = rmroiCellSIM;
    
    
            list_subInds      = 1:size(rmroiCell,1);
            % after seeing indiv plots removed 25 and 26
            % list_subInds      = [1:24,27:28]; 
            list_roiNames     = {'V1','V2','V3'};
            list_rmDescripts  = {'2D','3D'};
            list_dtNames      = {'2D','3D'};
            list_rmNames      = {'2D','3D'};
            titlestring       = 'Nvoxels2d2d';
            fnamestring       = 'Nvoxels2d2d';
            zlimbyan          = [-.5,.5];
            varexp = 0.5;        
    
        case 'number_vox2d3d'
            % Prepare data and defaults
            % now the data will not come from pRF fits. We will just generate
            % 2D gaussians randomly, and one group will have 10% of voxels
            % than the other one
            % 1st test: take just the modeled vertices, and take random 10%
            % 2nd test: do a proper randomization and create both datasets from
            % gaussians from scratch
            % TEST 1
            load(fullfile(prf2d3dRP,'DATA','mats','rmroicell_mini_vol_surf_models.mat'))
            % second column is voxels, substitute by a subset of vertices in
            % the first column
            % substitute for by funs...
            % decimation_factor = 10;
            rng(12345, 'twister')
            rmroiCellSIM = rmroiCell;
            for ns=1:30; for nr=1:3
                tmpData = rmroiCell{ns, nr, 1};
                tmpData2 = rmroiCell{ns, nr, 2};
                Nvertex = length(tmpData.x0);
                Nvertex2 = length(tmpData2.x0);
                rndInd = randi([1,Nvertex],[Nvertex2,1]);
                for nf=1:length(fieldnames(tmpData))
                    fnames = fieldnames(tmpData);
                    f = fnames{nf};
                    switch f
                        case {'vt','session','name'}
                            % disp(f)
                            continue
                        otherwise
                            ttd = tmpData.(f);
                            tmpData.(f) = ttd(rndInd);
                    end
                end
                rmroiCellSIM{ns, nr, 1} = tmpData;
            end;end
    
    
            rmroiCell = rmroiCellSIM;
    
    
            list_subInds      = 1:size(rmroiCell,1);
            % after seeing indiv plots removed 25 and 26
            % list_subInds      = [1:24,27:28]; 
            list_roiNames     = {'V1','V2','V3'};
            list_rmDescripts  = {'2D','3D'};
            list_dtNames      = {'2D','3D'};
            list_rmNames      = {'2D','3D'};
            titlestring       = 'Nvoxels2d3d';
            fnamestring       = 'Nvoxels2d3d';
            zlimbyan          = [-1,6];
            varexp = 0.5;        
        case 'hrlr'
            load(fullfile(prf2d3dRP,'DATA','rmroicell_HRLR.mat'))
            
            list_subInds      = 1:size(rmroiCell,1);
            list_roiNames     = {'V1','V2','V3'};
             %tasks = ['barHR','barLR']
            list_rmDescripts  = {'HR','LR'};
            list_dtNames      = {'HR','LR'};
            list_rmNames      = {'HR','LR'};
            titlestring       = 'HR - LR';
            fnamestring       = 'HRvsLR';
            zlimbyan          = [-2.5, 1];
            varexp = 0.2;
    
        case 'upsample'
            load(fullfile(prf2d3dRP,'DATA','rmroicell_mini_vol_surf_upsample.mat'))
            
            list_subInds      = 1:size(rmroiCell,1);
            list_roiNames     = {'V1','V2','V3'};
             %tasks = ['barHR','barLR']
            list_rmDescripts  = {'HR','LR'};
            list_dtNames      = {'HR','LR'};
            list_rmNames      = {'HR','LR'};
            titlestring       = 'HR - LR';
            fnamestring       = 'upsample';
            zlimbyan          = [-1, 5];
            varexp            = 0.2;
            rmroiCell         = flip(rmroiCell,3);
    
        otherwise
            error('Analysis case not defined')
    end
    
    % Create color map that goes through 0
    LR = zlimbyan(2)*100;
    LB = -1*zlimbyan(1)*100;
    red  = [1, 0, 0];
    white = [1,1,1];
    blue = [0, 0, 1];
    colors_bw = [linspace(blue(1),white(1),LB)', linspace(blue(2),white(2),LB)', linspace(blue(3), white(3),LB)'];
    colors_wr = [linspace(white(1),red(1),LR)', linspace(white(2),red(2),LR)', linspace(white(3), red(3),LR)'];
    colors_p = [colors_bw; colors_wr];
    
    % Read the generic params for coverage for all subjects
    cr.defaults.covfig.vfc = ff_vfcDefault();
    cr.defaults.covfig.vfc.list_roiNames = list_roiNames;
    % data types we want to look at
    cr.defaults.covfig.vfc.list_dtNames = list_dtNames;
    % names of the rm in each dt
    cr.defaults.covfig.vfc.list_rmNames = list_rmNames;
    
    
    
    %% Launch the function
       
    data_fname_mean = fullfile(cr.dirs.DATA,['RF_mean_' an '_.mat']);
    data_fname_individuals = fullfile(cr.dirs.DATA,['RF_individuals_' an '_.mat']);
    
    if recalculate || ~isfile(data_fname_mean) || ~isfile(data_fname_individuals)
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
                                              'minvarexp', varexp, ...
                                              'numboots', 10, ...
                                              'fname', fname, ...
                                              'vers','v01',...
                                              'method', 'avg', ...
                                              'density', false, ... 
                                              'invisible',true);
        
        save(data_fname_mean, 'RF_mean')
        save(data_fname_individuals, 'RF_individuals')
    else
        load(data_fname_mean)
        load(data_fname_individuals)
    end
    
    %% PLOT THEM FOR V1-3, DO BOOTSTRAPPING AND AVERAGE IT
    grid_size = 128;
    
    for nr=1:3
        ALL2d=RF_individuals{nr,1};
        ALL3d=RF_individuals{nr,2};
        
        MVALS = zeros(grid_size,grid_size,50);
        SVALS = zeros(grid_size,grid_size,50);
        DVALS = zeros(grid_size,grid_size,50);
        
        for kk=1:50
            % Remove 1 each time and create same plots with the remaining one
            nsubsminus1 = size(ALL2d,3)-1;
            randReplacement = datasample(1:nsubsminus1,nsubsminus1);
            all2d           = ALL2d(:,:,randReplacement);
            all3d           = ALL3d(:,:,randReplacement);
            
            % Calculate measures
            mval   = mean(all2d - all3d, 3);
            stdval = std(all2d - all3d, [],3);
            Cd     = zeros(grid_size,grid_size);
            for ii=1:grid_size;for jj=1:grid_size
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
        mrvNewGraphWin(['bootstraps' fnamestring 'FOV'],'wide',true);
        subplot(1,2,1)
        im1 = imagesc(Cd);axis equal;colormap(colors_p);colorbar;grid; hold on
        
        title([list_roiNames{nr} char(". d': mean 50 bootstraps ") titlestring])
        xlim([1,grid_size]);ylim([1,grid_size])
        xticks([1,grid_size/2,grid_size]); yticks([1,grid_size/2,grid_size])
        clim(zlimbyan)
        % Create the circles
        hold on
        C  = repmat([grid_size/2,grid_size/2],[3,1]);
        radii = [(grid_size/2)*(3/3), (grid_size/2)*(2/3), (grid_size/2)*(1/3)]';
        vc = viscircles(C,radii,'color',[0.5 0.5 0.5],'LineStyle','--', 'LineWidth',1,'EnhanceVisibility', false);
        xticklabels([-xdeg,0,xdeg]); yticklabels([-ydeg,0,ydeg])
        xlabel('X (degree)'); ylabel('Y (degree)')
    
        im1.Parent.FontSize = 18;
        % im1.Parent.XColor = [0.5, 0.5, 0.5]; 
        % im1.Parent.YColor = [0.5, 0.5, 0.5]; 
        im1.Parent.GridAlpha = 0.5;  % Make grid lines less transparent.
        im1.Parent.GridColor = [0.5, 0.5, 0.5]; 
        im1.Parent.LineWidth = 0.5;
        
        
        subplot(1,2,2)
        [X,Y] = meshgrid(1:grid_size,1:grid_size);
        XX = ((X-(grid_size/2))/(grid_size/2))*xdeg;
        YY = ((Y-(grid_size/2))/(grid_size/2))*ydeg;
        YY = flipud(YY);
        CdC = Cd;
        % Make concentring rings
        [x,y] = circlePoints(0.01);
        % 3/3 ring
        xx = round((128*x + 128)/2);
        yy = round((128*y + 128)/2);
        xx(xx==0)=1;
        yy(yy==0)=1;
        for ii=1:128; CdC(xx(ii),yy(ii)) = 0; end
        % 2/3 ring
        xx = round(((2/3)*128*x + 128)/2);
        yy = round(((2/3)*128*y + 128)/2);
        xx(xx==0)=1;
        yy(yy==0)=1;
        for ii=1:128; CdC(xx(ii),yy(ii)) = 0; end
        % 1/3 ring
        xx = round(((1/3)*128*x + 128)/2);
        yy = round(((1/3)*128*y + 128)/2);
        xx(xx==0)=1;
        yy(yy==0)=1;
        for ii=1:128; CdC(xx(ii),yy(ii)) = 0; end
    
        im2 = surf(XX,YY,Cd,CdC);
    
        xlabel('X (degree)'); ylabel('Y (degree)')
        zlabel("Cohen's d")
        xlim([-xdeg,xdeg])
        ylim([-ydeg,ydeg])
        zlim(zlimbyan)
        xticks([-xdeg,-(xdeg/2),0,(xdeg/2),xdeg])
        yticks([-ydeg,-(ydeg/2),0,(ydeg/2),ydeg])
        xticklabels({'-8','-4','0','4','8'})
        yticklabels({''})
        % viscircles(C,radii,'color',[0.5 0.5 0.5],'LineStyle','-', 'LineWidth',.75);
        im2.Parent.FontSize = 18;    
        % im2.Parent.XColor = [0.5, 0.5, 0.5]; 
        % im2.Parent.YColor = [0.5, 0.5, 0.5]; 
        im1.Parent.GridAlpha = 0.5;  % Make grid lines less transparent.
        im1.Parent.GridColor = [0.5, 0.5, 0.5]; 
        im1.Parent.LineWidth = 0.5;
    
        % Control de orientation
        azimuth = -45;
        elevation = 35.264;
        % Isometric view, c. f. https://en.wikipedia.org/wiki/Isometric_projection
        view(im2.Parent,azimuth,elevation);
        unitx = [1;0;0];
        unity = [0;1;0];
        unitz = [0;0;1];
        projectedunitx = rotx(elevation) * rotz(-azimuth) * unitx;
        projectedunity = rotx(elevation) * rotz(-azimuth) * unity;
        xlabelangle = atan2d(projectedunitx(3),projectedunitx(1));
        ylabelangle = -(180 - atan2d(projectedunity(3),projectedunity(1)));
        xlabelhandle = im2.Parent().XLabel;
        ylabelhandle = im2.Parent().YLabel;
        xlabelhandle.Rotation = xlabelangle;
        ylabelhandle.Rotation = ylabelangle;
        xlimits = xlim(im2.Parent);
        ylimits = ylim(im2.Parent);
        zlimits = zlim(im2.Parent);
        xmean = mean(xlimits);
        ymean = mean(ylimits);
        xbottom = xlimits(1);
        ybottom = ylimits(1);
        zbottom = zlimits(1);
        xlabelhandle.Position = [xmean (ybottom-1) (zbottom-1)];
        ylabelhandle.Position = [xbottom ymean zbottom];
        axis equal
        
        fname = ['FOV_Comparisons_ROI-' list_roiNames{nr} '_' fnamestring '_vfc.method_avg_varexp-' num2str(varexp)];
        set(0, 'DefaultFigureRenderer', 'painters');
    
    
    
        saveas(gcf, fullfile(cr.dirs.FIGPNG, [fname '.png']), 'png')
        saveas(gcf, fullfile(cr.dirs.FIGSVG,[fname '.svg']), 'svg')
    end
end



%% Individual plots
%{
for nr=1:3
    ALL2d=RF_individuals{nr,1};
    ALL3d=RF_individuals{nr,2};

    mrvNewGraphWin(['CrossVal' fnamestring 'FOV']);
    ha = tight_subplot(4,ceil(size(ALL3d,3)/4),[.03 .03],[.1 .01],[.01 .01]);
    subnames = 1:size(ALL3d,3);
    ve = varexp;
    for nn=1:size(ALL2d,3)
        all2d = ALL2d(:,:,nn);
        all3d = ALL3d(:,:,nn);
        axes(ha(nn));
        imagesc(all2d-all3d);axis equal;colormap(jet);colorbar;grid
        caxis([-.1,.1])
        % title(sprintf('Sub ind %i',nn))
        title(['ROI-' list_roiNames{nr} '_' fnamestring '_sub-' num2str(subnames(nn))])
        xlim([1,128]);ylim([1,128])
        xticks([1,64,128]); yticks([1,64,128])
        xticklabels([-xdeg,0,xdeg]); yticklabels([-ydeg,0,ydeg])
    
    end
    
    ha    = xlabel('Degs');
    ha(1) = ylabel('Degs');
    titlefile  = ['IndividualSubject\_' fnamestring '\_ROI-' list_roiNames{nr} ...
        '\_N-' num2str(size(ALL2d,3)) '\_VE-' num2str(100*ve) ];
    saveas(gcf, fullfile(cr.dirs.FIGPNG,[titlefile '.png']), 'png')
    saveas(gcf, fullfile(cr.dirs.FIGSVG,[titlefile '.svg']), 'svg')
end
close all
%}



