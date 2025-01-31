%% PSTH, zscore, Population Vector analysis for fam2novel experiment
%modified from popVec_analysis.m
%2024.01.20 AZ

if exist('d','var')
    clearvars -except d
else
    load('/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/social/d_social_20-Jan-2025.mat');
end

%%
ifFuncDAN = 0;
ifpMSN = 0;
ifNAc = 0;
ifOT = 0;

unfam_col1 = {[77/255, 1, 1]};
unfam_col2 = {[0,30/255,1]};
fam_col = {[1,0,1]};

% lineProps.col = get_colors(2);
lineProps.col = cat(1, fam_col, unfam_col1,unfam_col2);
lineProps.width = 1;
fr_range = [1 12];

% unit_maps = find([d.clust_params.ref_viols] < 2 & ...
%     [d.clust_params.mean_fr] > .5 & ...
%     ismember([d.clust_params.trode], [8,9,10,12,13,15,16])); % [8,9,10,12,13,15,16] %[1,2,3,4,5,6,7,11,14]);

if ifpMSN 
    if ifNAc
        unit_maps = find([d.clust_params.region_coding]==1 & ...
            [d.clust_params.mean_fr]>.25&[d.clust_params.mean_fr]<5);
    elseif ifOT
        unit_maps = find([d.clust_params.region_coding]==2 & ...
            [d.clust_params.mean_fr]>.25&[d.clust_params.mean_fr]<5); 
    else  %both NAc and OT
        unit_maps = find(ismember([d.clust_params.region_coding],[1 2]) & ...
            [d.clust_params.mean_fr]>.25&[d.clust_params.mean_fr]<5); 
    end
elseif ifFuncDAN
%FuncDANs units
    unit_maps = find([d.clust_params.region_coding]==3 & ...
        [d.clust_params.mean_fr]>fr_range(1) & [d.clust_params.mean_fr]<fr_range(2) & ...
        [d.clust_params.funcDAN_familiar]==1 | [d.clust_params.funcDAN_novel1]==1 | [d.clust_params.funcDAN_novel2]==1);
else
%All putative DANs
    unit_maps = find([d.clust_params.region_coding]==3 & ...
        [d.clust_params.mean_fr]>fr_range(1) & [d.clust_params.mean_fr]<fr_range(2));
end

ops = [];
ops.binsize = 0.1;
ops.pre = 4; %seconds before stim for baseline
ops.post = 10;
ops.response = [0 1];
% ops.baseline = [-1 0];
ops.baseline = [-1.2 -0.2];
ops.smoothing = 3;
ops.average_trials = 1; % one trial; not bool
ops.average_baseline = 1;
ops.shuffle_trial_order = 0;
ops.sniff_align = 0;
% ops.include_trials = 20:30;

% [f, f2, stats] = plot_P3_popVec_temporal_evolution_overlaid(d,unit_maps,ops);


%% PSTH analysis

ops.trial_subselect = 'cut 1-5';
% blocked
[psth_score_cell, time] = compute_all_psth(d, unit_maps, ops); 
response_bins = find(round(time,1)==ops.response(1)):find(round(time,1)==ops.response(2))-1;
y_mean = cat(1, mean(psth_score_cell{1,1},1), mean(psth_score_cell{1,2},1),mean(psth_score_cell{1,3},1)); 
y_sem = cat(1, sem(psth_score_cell{1,1},1), sem(psth_score_cell{1,2},1), sem(psth_score_cell{1,3},1)); 

f=figure;
mseb(time+ops.binsize, y_mean, y_sem, lineProps);
xlabel('relative time (s)');
ylabel('firing rate (Hz)');
legend('familiar','novel1','novel2','FontSize',10)
title('VTA_non-negative_meanPSTH_- 1st 5 tr','Interpreter','none','FontSize',15)
% set_fonts();
% text(9,4.2,'n = ' + string(numel(unit_maps)),'FontSize',10) %adjust the position as needed  
text(0.8,0.8, ['n = ',num2str(numel(unit_maps))],'FontSize',14, 'Units','normalized')
box('off');
f.Units = 'centimeters';
xlim([-2 4])
ylim([3 15])
% f.Position =  [3 3 3 3];
% exportgraphics(f,'AON_blocked_pooled_meanPSTH.pdf','ContentType','vector','BackgroundColor','none');
%%
%Adjust by hand the size of the figure window before saving
saveas(gcf,'/zi-flstorage/data/Angela/DATA/TD23/Plots/fam2novel/Remove_first5tr/VTA_non_negative_meanPSTH.png');

%% Stats - PSTH

mean_PSTHs_resp_bins = [mean(psth_score_cell{1,1}(:,response_bins),2) mean(psth_score_cell{1,2}(:,response_bins),2) mean(psth_score_cell{1,3}(:,response_bins),2)];
% [p, tb1,stats] = anova1(mean_PSTHs_resp_bins,["familiar","novel1","novel2"]);
[p_famnov1, h_famnov1,stats_famnov1] = signrank(mean_PSTHs_resp_bins(:,1),mean_PSTHs_resp_bins(:,2));
[p_famnov2, h_famnov2,stats_famnov2] = signrank(mean_PSTHs_resp_bins(:,1),mean_PSTHs_resp_bins(:,3));
[p_nov1nov2, h_nov1nov2,stats_nov1nov2] = signrank(mean_PSTHs_resp_bins(:,2),mean_PSTHs_resp_bins(:,3));

% not significant

%% Plot the mean response z-score of the population
ops.trial_subselect = 'cut 1-5';
[zscore_score_cell, time] = compute_all_zscore(d, unit_maps, ops);
y_mean = cat(1, mean(zscore_score_cell{1,1},1), mean(zscore_score_cell{1,2},1),mean(zscore_score_cell{1,3},1)); 
y_sem = cat(1, sem(zscore_score_cell{1,1},1), sem(zscore_score_cell{1,2},1), sem(zscore_score_cell{1,3},1)); 

f=figure;
mseb(time+ops.binsize, y_mean, y_sem, lineProps);
ylabel('Response Z-Score');
xlabel('relative time (s)');
legend('familiar','novel1','novel2','FontSize',10)
title('pDANs_excited_only_zscore','Interpreter','none','FontSize',15)
xlim([-2 4]);
% ylim([-2 10]);
text(0.8,0.8, ['n = ',num2str(numel(unit_maps))],'FontSize',14, 'Units','normalized')
box('off');
f.Units = 'centimeters';
% f.Position =  [3 3 3 3];
%%
%Adjust by hand the size of the figure window before saving
saveas(gcf,'/zi-flstorage/data/Angela/DATA/TD23/Plots/fam2novel/Remove_first5tr/pDANs_excited_only_zscore.png');

%% stats - zscore

mean_zscore_resp_bins = [mean(zscore_score_cell{1,1}(:,response_bins),2) mean(zscore_score_cell{1,2}(:,response_bins),2) mean(zscore_score_cell{1,3}(:,response_bins),2)];
[p, tb1,stats] = anova1(mean_zscore_resp_bins,["familiar","novel1","novel2"]);

%% Plot response pie charts

ops.Colormap =  [...
    1, 1, 1;   %white
    1, 0, 0;   %red
    0, 0, 1];  %blue
ops.activation_threshold = 2;

[f1,ops, excited, inhibited] = plot_activation_piechart(d,unit_maps,ops);


% Do a fisher exact test to compare response behavior
x = table([excited(1)+inhibited(1);excited(2)+inhibited(2)],...
    [numel(unit_maps)-(excited(1)+inhibited(1));numel(unit_maps)-(excited(2)+inhibited(2))],'VariableNames',{'Change','NoChange'},'RowNames',{'Familiar','Non-familiar'});
[h,p,stats] = fishertest(x);

save('activation_stats','h', 'p', 'stats');

%% Plot the Euclidean distance to baseline of the population vector

clearvars -except d unit_maps
ops.smoothing = 3;
ops.average_trials = 1; % one trial; not bool
ops.average_baseline = 1;
ops.shuffle_trial_order = 0;

f = plot_popVec_temporal_evolution_overlaid_TD23(d,unit_maps,ops);
title('Euclidian OT_pMSNs','Interpreter','none','FontSize',15);
% set_fonts();
% f.Units = 'centimeters';
% f.Position =  [3 3 3 3];
% legend('off')
% exportgraphics(f,'VDB_popVecDistToBaseline.pdf','ContentType','vector','BackgroundColor','none');
%%
saveas(gcf,'/zi-flstorage/data/Angela/DATA/TD23/Plots/fam2novel/Euclidean_OT_pMSNs.png');
% close all;

%%

% test: paired test
[h,p,~,stats]=ttest(mean(psth_score_cell{1,1}(:,response_bins),2),mean(psth_score_cell{1,2}(:,response_bins),2));
stats.p = p;
stats.source = [mean(psth_score_cell{1,1}(:,response_bins),2),mean(psth_score_cell{1,2}(:,response_bins),2)];

% test early and late window
response_bins_early = find(round(time,1)==0):find(round(time,1)==0.5)-1;
response_bins_late = find(round(time,1)==0.5):find(round(time,1)==1)-1;
[h,p_early,~,stats_early]=ttest(mean(psth_score_cell{1,1}(:,response_bins_early),2),mean(psth_score_cell{1,2}(:,response_bins_early),2));
[h,p_late,~,stats_late]=ttest(mean(psth_score_cell{1,1}(:,response_bins_late),2),mean(psth_score_cell{1,2}(:,response_bins_late),2));
stats_early.p = p_early; stats_late.p = p_late;
save('AON_blocked_pooled_meanPSTH.mat','stats','stats_early','stats_late');
writetable(array2table(stats.source),'AON_blocked_pooled_meanPSTH_source.xlsx');
writetable(array2table([mean(psth_score_cell{1,1}(:,response_bins_early),2),mean(psth_score_cell{1,2}(:,response_bins_early),2)]),'AON_blocked_pooled_meanPSTH_sourceEarly.xlsx');
writetable(array2table([mean(psth_score_cell{1,1}(:,response_bins_late),2),mean(psth_score_cell{1,2}(:,response_bins_late),2)]),'AON_blocked_pooled_meanPSTH_sourceLate.xlsx');

f=figure;
mseb(time+ops.binsize, y_mean, y_sem, lineProps);
xlabel('relative time (s)');
ylabel('firing rate (Hz)');
title({['first 500ms: p=',num2str(round(p_early,4))], ['last 500ms: p=',num2str(round(p_late,4))]});
set_fonts();
xlim([-1 2.5]);
ylim([3 9]);
box('off');
f.Units = 'centimeters';
f.Position =  [3 3 3 3];
exportgraphics(f,'AON_blocked_pooled_meanPSTH_earlyLateTest.pdf','ContentType','vector','BackgroundColor','none');


