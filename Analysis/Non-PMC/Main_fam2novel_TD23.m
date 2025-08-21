%% PSTH, zscore, Population Vector analysis for fam2novel experiment
%modified from popVec_analysis.m
%2024.01.20 AZ

if exist('d','var')
    clearvars -except d
else
    load('/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/social/d_social_04-Feb-2025.mat');
end

%% Unit selection
ifpMSN = 0;
ifNAc = 0;
ifOT = 0;
ifExc =1;
ifInh = 0;
ifNoResp = 1;

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
else
%All putative DANs
    unit_maps = find([d.clust_params.region_coding]==3 & ...
        [d.clust_params.mean_fr]>fr_range(1) & [d.clust_params.mean_fr]<fr_range(2));
end

ex_fam = [d.clust_params(unit_maps).ex_fam];
ex_nov1 = [d.clust_params(unit_maps).ex_nov1];
ex_nov2 = [d.clust_params(unit_maps).ex_nov2];
inh_fam = [d.clust_params(unit_maps).inh_fam];
inh_nov1 = [d.clust_params(unit_maps).inh_nov1];
inh_nov2 = [d.clust_params(unit_maps).inh_nov2];

excited_units = (ex_fam==1)|(ex_nov1==1)|(ex_nov2==1)&(inh_fam==0)&(inh_nov1==0)&(inh_nov2==0);
inhibited_units = (inh_fam==1)|(inh_nov1==1)|(inh_nov2==1)&(ex_fam==0)&(ex_nov1==0)&(ex_nov2==0);
non_inhibited_units = (inh_fam==0)&(inh_nov1==0)&(inh_nov2==0);

if ifExc
    if ifNoResp
        unit_maps = unit_maps(non_inhibited_units);
    else
        unit_maps = unit_maps(excited_units);
    end
elseif ifInh
    unit_maps = unit_maps(inhibited_units);
end


%% ops
ops = [];
ops.binsize = 0.01;
% ops.binsize = 0.1;
ops.pre = 3; %seconds before stim for baseline
ops.post = 5;
ops.response = [0.05 1];
% ops.baseline = [-1 0];
ops.baseline = [-2 0];
ops.smoothing = 3;
ops.average_trials = 1; % one trial; not bool
ops.average_baseline = 1;
ops.shuffle_trial_order = 0;
ops.sniff_align = 0;
% ops.include_trials = 20:30;

% [f, f2, stats] = plot_P3_popVec_temporal_evolution_overlaid(d,unit_maps,ops);


%% PSTH analysis

% ops.trial_subselect = 'cut 1-5';
% blocked
[psth_score_cell, time] = compute_all_psth(d, unit_maps, ops); 
response_bins = find(round(time,3)==ops.response(1)):find(round(time,3)==ops.response(2))-1;
y_mean = cat(1, mean(psth_score_cell{1,1},1), mean(psth_score_cell{1,2},1),mean(psth_score_cell{1,3},1)); 
y_sem = cat(1, sem(psth_score_cell{1,1},1), sem(psth_score_cell{1,2},1), sem(psth_score_cell{1,3},1)); 

f=figure;
mseb(time+ops.binsize, y_mean, y_sem, lineProps);
xlabel('relative time (s)');
ylabel('firing rate (Hz)');
legend('familiar','novel1','novel2','FontSize',10)
title('OT_non-inh_pMSNs_meanPSTH','Interpreter','none','FontSize',15)
% set_fonts();
% text(9,4.2,'n = ' + string(numel(unit_maps)),'FontSize',10) %adjust the position as needed  
text(0.8,0.8, ['n = ',num2str(numel(unit_maps))],'FontSize',14, 'Units','normalized')
box('off');
f.Units = 'centimeters';
xlim([-1 2])
% ylim([3 15])
% f.Position =  [3 3 3 3];
% exportgraphics(f,'AON_blocked_pooled_meanPSTH.pdf','ContentType','vector','BackgroundColor','none');
%%
%Adjust by hand the size of the figure window before saving
saveas(gcf,'/zi-flstorage/data/Angela/DATA/TD23/Plots/fam2novel/All_trials/10ms_bin/OT_non-inh_meanPSTH.png');

%% Stats - PSTH

mean_PSTHs_resp_bins = [mean(psth_score_cell{1,1}(:,response_bins),2) mean(psth_score_cell{1,2}(:,response_bins),2) mean(psth_score_cell{1,3}(:,response_bins),2)];
% [p, tb1,stats] = anova1(mean_PSTHs_resp_bins,["familiar","novel1","novel2"]);
[p_famnov1, h_famnov1,stats_famnov1] = signrank(mean_PSTHs_resp_bins(:,1),mean_PSTHs_resp_bins(:,2));
[p_famnov2, h_famnov2,stats_famnov2] = signrank(mean_PSTHs_resp_bins(:,1),mean_PSTHs_resp_bins(:,3));
[p_nov1nov2, h_nov1nov2,stats_nov1nov2] = signrank(mean_PSTHs_resp_bins(:,2),mean_PSTHs_resp_bins(:,3));

%% Boxplot with individual points and connecting lines

b = boxplot_fam2nov(mean_PSTHs_resp_bins);


%% Plot the mean response z-score of the population
% ops.trial_subselect = 'cut 1-5';
[zscore_score_cell, time] = compute_all_zscore(d, unit_maps, ops);
y_mean = cat(1, mean(zscore_score_cell{1,1},1), mean(zscore_score_cell{1,2},1),mean(zscore_score_cell{1,3},1)); 
y_sem = cat(1, sem(zscore_score_cell{1,1},1), sem(zscore_score_cell{1,2},1), sem(zscore_score_cell{1,3},1)); 

f=figure;
mseb(time+ops.binsize, y_mean, y_sem, lineProps);
ylabel('Response Z-Score');
xlabel('relative time (s)');
legend('familiar','novel1','novel2','FontSize',10)
title('pDANs_inhibited_only_zscore','Interpreter','none','FontSize',15)
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
[p_famnov1, h_famnov1,stats_famnov1] = signrank(mean_zscore_resp_bins(:,1),mean_zscore_resp_bins(:,2));
[p_famnov2, h_famnov2,stats_famnov2] = signrank(mean_zscore_resp_bins(:,1),mean_zscore_resp_bins(:,3));
[p_nov1nov2, h_nov1nov2,stats_nov1nov2] = signrank(mean_zscore_resp_bins(:,2),mean_zscore_resp_bins(:,3));


%% Plot response pie charts
% Unused
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
title('Euclidian excited_only_pDANs','Interpreter','none','FontSize',15);
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


