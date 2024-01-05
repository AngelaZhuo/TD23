function pupil_dia = pupil_load_and_get_diameter(Videolist_csv, likelihood_threshold, savedir)
%% This function loads the csv output files from DLC from the 8-point pupil network and get mean diameter
% 
%
%
plotter = 0;

for vid = 1:numel(Videolist_csv)
%% Load Output data (as csv)

    [fdir,fname,fext]=fileparts(Videolist_csv{vid});
    coords = readtable(Videolist_csv{vid},'delimiter',',','headerlines',1);

%% Find outliers with low likelihood of correct pose estimation

    coords_clean = coords;
    % for every marker find timepoints of low likelihood
    for m = 4:3:25
        % set NaN for x and y coords of low likelihood timepoints
        coords_clean.(m-1)(coords.(m) < likelihood_threshold) = NaN;
        coords_clean.(m-2)(coords.(m) < likelihood_threshold) = NaN;
    end


%% Get diameter from opposing markers
    d1 = diag(pdist2(table2array(coords_clean(:,[2, 3])), table2array(coords_clean(:,[14, 15])), 'euclidean')); %nort-south
    d2 = diag(pdist2(table2array(coords_clean(:,[5, 6])), table2array(coords_clean(:,[17, 18])), 'euclidean')); % NE - SW
    d3 = diag(pdist2(table2array(coords_clean(:,[8, 9])), table2array(coords_clean(:,[20, 21])), 'euclidean')); % E - W
    d4 = diag(pdist2(table2array(coords_clean(:,[11, 12])), table2array(coords_clean(:,[23, 24])), 'euclidean')); % SE - NW

    % get median across diameters
    d_mean = nanmedian(cat(2,d1,d2,d3,d4),2);
    
    % outlier frames are frames where no single diameter could be extracted
    outlier_frames = find(isnan(d_mean));

    % plot:
    if plotter
        figure(1);
        hold on;
        plot(d_mean);
        ax=gca;
        for sx=1:length(outlier_frames)
            line([outlier_frames(sx),outlier_frames(sx)],[0,ax.YLim(2)],'color','r');
        end
        ax.YLabel.String='Pupil Diameter';
        ax.XLabel.String='Frame [30 fps]';
        legend('Outlier Frames','Location','NorthEast')
        title(fname,'Interpreter','none')

        set(gcf, 'InvertHardcopy', 'off')
    %     print('-dpsc',fullfile(savedir,['Pupil_uncorrected.ps']) ,'-r200','-append');
        saveas(gcf,fullfile(savedir,[fname,'.png']));
        close all;
    end
    % create pupil_dia string array
    pupil_dia(vid).name = fname;
    pupil_dia(vid).length = length(d_mean);
    pupil_dia(vid).d_mean = d_mean;
    pupil_dia(vid).outliers = outlier_frames;
    pupil_dia(vid).numb_outliers = numel(outlier_frames);

end
