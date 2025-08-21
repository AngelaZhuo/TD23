%% David's script for getting the odor-tuning profile of units
% Modified for the use of TD23 fam2novel exp.

function d = compute_exIn_TD23(d)
unit_maps = 1:numel(d.clust_params);
for ii = 1:numel(d.clust_params)
% d.clust_params(ii).exclude = 0; 
d.clust_params(ii).ex_fam = 0;
d.clust_params(ii).ex_nov1 = 0;
d.clust_params(ii).ex_nov2 = 0;
d.clust_params(ii).inh_fam = 0;
d.clust_params(ii).inh_nov1 = 0;
d.clust_params(ii).inh_nov2 = 0;
end
ops = [];
ops.pre = 5;
ops.post = 2.5;
ops.binsize = .1;
% ops.baseline = [-4 0];
ops.baseline = [-2 -0.2]; %to avoid the small FR increase at -3s
ops.response = [0 1];
ops.sniff_align = 0;
ops.lfp_align = 0;
% 
[condition_cell, time_base] = compute_all_psth(d, unit_maps, ops); % firing rates for all units
response_bins = find(time_base==ops.response(1)):find(time_base==ops.response(2));
baseline_bins = find(time_base==ops.baseline(1)):find(time_base==ops.baseline(2));
% prepare timebase
time_base = -ops.pre:ops.binsize:ops.post;
time_base(end) = [];
% get number of conditions
trialmatrix = d.events{1,1};
conditions = unique([trialmatrix([trialmatrix.odor_dur]~=0).case_num]); %omit non-odor trials
num_conditions = numel(conditions);
for ii = 1:numel(unit_maps)
% spikes for this unit
    spxtimes = d.spikes{1,(unit_maps(ii))};
    % trialtimes for the session of this unit
    events = d.events{1,d.map(unit_maps(ii))};
%     odor_num = unique([events.case_num]);
    odor_num = unique([events([events.odor_dur]~=0).case_num]);
    for cond = 1:size(condition_cell,2) 
        % get binned spike counts
        trialtimes = [events([events.case_num]==odor_num(cond)).fv_on];
        [binned_array,~,~] = get_psth_ba_zscore(spxtimes,trialtimes,ops);
        % test familiar (paired nonparametric)
        baseline_vector = mean(binned_array(:,baseline_bins),2);
        response_vector = mean(binned_array(:,response_bins),2);
        [p,~] = signrank(baseline_vector,response_vector);
        diff = response_vector - baseline_vector;
%         if p<.025 
        if p<0.01
            if numel(diff(diff<0))>numel(diff(diff>0))
                switch cond
                    case 1
                        d.clust_params(unit_maps(ii)).inh_fam = 1;
                    case 2
                        d.clust_params(unit_maps(ii)).inh_nov1 = 1;
                    case 3
                        d.clust_params(unit_maps(ii)).inh_nov2 = 1;
                end
            elseif numel(diff(diff>0))>numel(diff(diff<0))
                switch cond
                    case 1
                        d.clust_params(unit_maps(ii)).ex_fam = 1;
                    case 2
                        d.clust_params(unit_maps(ii)).ex_nov1 = 1;
                    case 3
                        d.clust_params(unit_maps(ii)).ex_nov2 = 1;
                end
            else
                warning('unit '+ string(ii) + ' has low p but median difference is zero')
                switch cond
                    case 1
                        d.clust_params(unit_maps(ii)).ex_fam = NaN;
                        d.clust_params(unit_maps(ii)).inh_fam = NaN;
                    case 2
                        d.clust_params(unit_maps(ii)).ex_nov1 = NaN;
                        d.clust_params(unit_maps(ii)).inh_nov1 = NaN;
                    case 3
                        d.clust_params(unit_maps(ii)).ex_nov2 = NaN;
                        d.clust_params(unit_maps(ii)).inh_nov2 = NaN;
                end
            end
        else
            switch cond
                case 1 
                    d.clust_params(unit_maps(ii)).ex_fam = 0;
                    d.clust_params(unit_maps(ii)).inh_fam = 0;
                case 2
                    d.clust_params(unit_maps(ii)).ex_nov1 = 0;
                    d.clust_params(unit_maps(ii)).inh_nov1= 0;
                case 3
                    d.clust_params(unit_maps(ii)).ex_nov2 = 0;
                    d.clust_params(unit_maps(ii)).inh_nov2 = 0;
            end
        end
    %parse to preallocated image matrix
    % condition_cell{1,cond}(ii,:) = curr_psth;
    end
end
end
