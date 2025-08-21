%% Find responsive units from fam2novel exp.
% Categorize units into excited, inhibited and non-resp by testing the response bins to the baseline bins (500ms)
% Cut off the first 5 trials from each odor trials

ops.baseline = [-1.2 -0.2]; %take 500ms baseline to be able to perform signrank 
ops.trial_subselect = 'cut 1-5';
time_base = -ops.pre:ops.binsize:ops.post;
time_base(end) = [];
time_base = round(time_base,10); %Fix floating-point problem
baseline_bins = find(ops.baseline(1)==time_base):find(ops.baseline(2)==time_base)-1;
response_bins_early = find(round(time_base,1)==0):find(round(time_base,1)==0.5)-1;  %first 500ms response window
response_bins_late = find(round(time_base,1)==0.5):find(round(time_base,1)==1)-1;   %second 500ms response window

trialmatrix = d.events{1,1};
conditions = unique([trialmatrix([trialmatrix.odor_dur]~=0).case_num]); %omit non-odor trials
num_conditions = numel(conditions);
alpha = 0.01;
neu_resp_tuning = cell(1,num_conditions);  %excited units = 1; inhibited units = -1; non-resp = 0; 
for cond = 1:num_conditions
    neu_resp_tuning{1,cond} = zeros(numel(unit_maps),2);
end

for um = 1:numel(unit_maps)
    spxtimes = d.spikes{1,(unit_maps(um))};
    events = d.events{1,d.map(unit_maps(um))};
    for cond = 1:num_conditions
        trialtimes = [events([events.case_num]==conditions(cond)).fv_on];
        if ops.trial_subselect
            switch ops.trial_subselect
                case 'cut 1-5'
                    trialtimes = trialtimes(6:end);
            end
        end
    
    [binned_array,~,~] = get_psth_ba_zscore(spxtimes,trialtimes,ops);
    mean_baseline_per_trial = mean(binned_array(:,baseline_bins),2);
    mean_first500ms_per_trial = mean(binned_array(:,response_bins_early),2);
    mean_second500ms_per_trial = mean(binned_array(:,response_bins_late),2);
    [p_early,~, stats_early] = signrank(mean_baseline_per_trial,mean_first500ms_per_trial);
    [p_late,~, stats_late] = signrank(mean_baseline_per_trial,mean_second500ms_per_trial);
    if p_early<alpha
        if mean(mean_baseline_per_trial) < mean(mean_first500ms_per_trial)   %Use mean because median could be equal even though p<alpha
            neu_resp_tuning{1,cond}(um,1) = 1;
        elseif mean(mean_baseline_per_trial) > mean(mean_first500ms_per_trial)
            neu_resp_tuning{1,cond}(um,1) = -1;
        else
            warning('strange stats result, unit '+ string(um))
        end
    else
        neu_resp_tuning{1,cond}(um,1) = 0;
    end
    if p_late<alpha
        if mean(mean_baseline_per_trial) < mean(mean_second500ms_per_trial)
            neu_resp_tuning{1,cond}(um,2) = 1;
        elseif mean(mean_baseline_per_trial) > mean(mean_second500ms_per_trial)
            neu_resp_tuning{1,cond}(um,2) = -1;
        else
            warning('strange stats result, unit ' + string(um))
        end
    else
        neu_resp_tuning{1,cond}(um,2) = 0;
    end

    end
end

%% Labeling units respond to 0, 1, 2, or 3 odors

load('/home/yi.zhuo/Documents/Github/TD23/Analysis/Non-PMC/pDANs_resp_tuning_alpha0.01.mat')

for um = 1:numel(unit_maps)
    curr_unit_tuning = [];
    for cond = 1:3
        curr_unit_tuning = [curr_unit_tuning neu_resp_tuning{1,cond}(um,:)];
    end
    exc_cond1 = curr_unit_tuning(1:2)==1;
    exc_cond2 = curr_unit_tuning(3:4)==1;
    exc_cond3 = curr_unit_tuning(5:6)==1;
    inh_cond1 = curr_unit_tuning(1:2)==-1;
    inh_cond2 = curr_unit_tuning(3:4)==-1;
    inh_cond3 = curr_unit_tuning(5:6)==-1;
    exc_count = sum([any(exc_cond1), any(exc_cond2), any(exc_cond3)]);
    inh_count = sum([any(inh_cond1), any(inh_cond2), any(inh_cond3)]);
    if exc_count > 0 
        if inh_count > 0 
            label(um) = "mixed";
        elseif exc_count == 1
            label(um) = "excited for 1";
        elseif exc_count == 2
            label(um) = "excited for 2";
        elseif exc_count == 3
            label(um) = "excited for all";
        end
    elseif inh_count > 0
        if inh_count == 1
            label(um) = "inhibited for 1";
        elseif inh_count == 2 
            label(um) = "inhibited for 2";
        elseif inh_count == 3
            label(um) = "inhibited for all";
        end
    else
        label(um) = "no response";
    end
end

%% Tables adn pie charts

exc_for1 = nnz(label == "excited for 1");
exc_for2 = nnz(label == "excited for 2");
exc_for3 = nnz(label == "excited for all");
mixed = nnz(label == "mixed");
inh_for1 = nnz(label == "inhibited for 1");
inh_for2 = nnz(label == "inhibited for 2");
inh_for3 = nnz(label == "inhibited for all");
no_resp = nnz(label == "no response");

Category = ["excited for 1";"excited for 2";"excited for all";"inhibited for 1";"inhibited for 2";"inhibited for all";"mixed";"no response"];
Number = [exc_for1;exc_for2;exc_for3;inh_for1;inh_for2;inh_for3;mixed;no_resp];
Percentage = (Number./numel(unit_maps)) * 100; 
Table_unit_labels = table(Category,Number,Percentage);
writetable(Table_unit_labels,'/zi-flstorage/data/Angela/DATA/TD23/Plots/fam2novel/VTAunits_labels.xls')

Explode = [0 1 1 1 1 1 1 1];  %distance between pie slices
pie([numel(unit_maps)-exc_for1-exc_for2-exc_for3-inh_for1-inh_for2-inh_for3-mixed,exc_for1,exc_for2,exc_for3,mixed,inh_for1,inh_for2,inh_for3],Explode,'%.1f%%');
legend1=legend('no response','excited_for1','excited_for2','excited_for_all','mixed','inhited_for1','inhibited_for2','inhibited_for3');
set(legend1,...
    'Position',[15 1 1 1],...
    'Orientation','horizontal',...
    'FontSize',8);
colororder("earth")
