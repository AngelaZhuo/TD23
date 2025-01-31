function f1 = plot_popVec_temporal_evolution_overlaid_TD23(d,unit_maps,ops)
%%
% modified from plot_P3_popVec_temporal_evolution_overlaid.m, 20250125 AZ

% if ~isfield(ops,'cmap')
%     ops.cmap = ;
% end
% lineProps.col = {[0 150/255 94/255],[213/255 173/255 0]};
if ~isfield(ops, 'response')
    ops.response = [0 1];
end
if ~isfield(ops,'baseline')
    ops.baseline = [-1 0];
end
unfam_col1 = {[77/255, 1, 1]};
unfam_col2 = {[0,30/255,1]};
fam_col = {[1,0,1]};

lineProps.col = cat(1, fam_col, unfam_col1,unfam_col2);
lineProps.width = 1;

%% Compute image


% build spike count population vector
[pop_vec,ops] = build_PopVec(d,unit_maps,ops);

% calculate distance from baseline over bins
euclidian = compute_Euclidean_distance_from_baseline_TD23(pop_vec,ops);

% prepare timebase
time_base = -ops.pre:ops.binsize:ops.post;
time_base(end) = [];

% response and baseline bins
response_bins = find(round(time_base,1)==ops.response(1)):find(round(time_base,1)==ops.response(2))-1;
% baseline_bins = find(round(time_base,1)==ops.baseline(1)):find(round(time_base,1)==ops.baseline(2))-1;

% events = d.events{1,(d.map(unit_maps(1)))};
% odor_nums = unique([events.case_num]);

%% Plot

f1 = figure('name','Population Vector temporal evolution');
% fullscreen(f1);

% y values for plotting: first row: familiar juvenile, sceond row:
% unfamiliar juvenile 1, third row: unfamiliar juvenile 2
y_mean = zeros(3,numel(time_base));
y_sem = zeros(3,numel(time_base));
for cond = 1:size(y_mean,1)
%     if ops.average_baseline
%         y_mean(cond,:) = nanmean(euclidian{3,cond});
%         y_sem(cond,:) = sem(euclidian{3,cond});
%     else
    y_mean(cond,:) = nanmean(euclidian{1,cond});
    y_sem(cond,:) = sem(euclidian{1,cond});
%     end
end
mseb(time_base,y_mean,y_sem,lineProps,1);

% [h, p] = ttest2(nanmean(euclidian{1,1}(:,response_bins),2),nanmean(euclidian{1,2}(:,response_bins),2));
% [h, p] = ttest(nanmean(euclidian{1,1}(:,response_bins),2),nanmean(euclidian{1,2}(:,response_bins),2));
% euclidian_resp_bins = [nanmean(euclidian{1,1}(:,response_bins),2) nanmean(euclidian{1,2}(:,response_bins),2) nanmean(euclidian{1,3}(:,response_bins),2)];
% p = anova1(euclidian_resp_bins,["familiar","novel1","novel2"]);

% xlim([-1 2.5])
% ylim([.9*min(min(y_mean)), 1.1*max(max(y_mean))]);
legend('familiar','novel1','novel2');
ylabel({'Euclidian Distance', ... 
    'from baseline'});
xlabel('relative time (s)')
% text(0.8,0.8, ['n = ',num2str(numel(unit_maps)),'; p = ',num2str(p)],'FontSize',14, 'Units','normalized')
text(0.8,0.8, ['n = ',num2str(numel(unit_maps))],'FontSize',14, 'Units','normalized')
set(gca,'FontSize',14);


end