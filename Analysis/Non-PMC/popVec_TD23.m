%% Population Vector analysis
%modified from popVec_analysis.m
%2024.12.19 AZ
clear
load('/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/social/d_social_19-Dec-2024.mat');


%%
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

%FuncDANs units
unit_maps = find([d.clust_params.region_coding]==3 & ...
    [d.clust_params.mean_fr]>fr_range(1) & [d.clust_params.mean_fr]<fr_range(2) & ...
    [d.clust_params.funcDAN_familiar]==1 | [d.clust_params.funcDAN_novel1]==1 | [d.clust_params.funcDAN_novel2]==1);
%All putative DANs
% unit_maps = find([d.clust_params.region_coding]==3 & ...
%     [d.clust_params.mean_fr]>fr_range(1) & [d.clust_params.mean_fr]<fr_range(2));

ops = [];
ops.binsize = 0.1;
ops.pre = 4; %seconds before stim for baseline
ops.post = 10;
ops.response = [0 1];
ops.baseline = [-1 0];
ops.smoothing = 3;
ops.average_trials = 1; % one trial; not bool
ops.average_baseline = 1;
ops.shuffle_trial_order = 0;
ops.sniff_align = 0;
% ops.include_trials = 20:30;

% [f, f2, stats] = plot_P3_popVec_temporal_evolution_overlaid(d,unit_maps,ops);



%% PSTH analysis


% blocked
[psth_score_cell, time] = compute_all_psth(d, unit_maps, ops); 
response_bins = find(round(time,1)==ops.response(1)):find(round(time,1)==ops.response(2))-1;
y_mean = cat(1, mean(psth_score_cell{1,1},1), mean(psth_score_cell{1,2},1),mean(psth_score_cell{1,3},1)); 
y_sem = cat(1, sem(psth_score_cell{1,1},1), sem(psth_score_cell{1,2},1), sem(psth_score_cell{1,3},1)); 

f=figure;
mseb(time+ops.binsize, y_mean, y_sem, lineProps);
xlabel('relative time (s)');
ylabel('firing rate (Hz)');
legend('familiar','novel1','novel2')
title('20240707_FuncDANs_meanPSTH','Interpreter','none')
% set_fonts();
xlim([-1 2.5]);
ylim([3 14]);
text(2.3,12.7,'n = 47')  %optional, adjsut as needed
box('off');
f.Units = 'centimeters';
f.Position =  [3 3 3 3];
exportgraphics(f,'AON_blocked_pooled_meanPSTH.pdf','ContentType','vector','BackgroundColor','none');

%% Plot the mean response z-score of the population
[zscore_score_cell, time] = compute_all_zscore(d, unit_maps, ops);
y_mean = cat(1, mean(zscore_score_cell{1,1},1), mean(zscore_score_cell{1,2},1),mean(zscore_score_cell{1,3},1)); 
y_sem = cat(1, sem(zscore_score_cell{1,1},1), sem(zscore_score_cell{1,2},1), sem(zscore_score_cell{1,3},1)); 

f=figure;
mseb(time+ops.binsize, y_mean, y_sem, lineProps);
ylabel('Response Z-Score');
xlabel('Time [s]');


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


