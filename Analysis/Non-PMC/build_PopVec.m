function [pop_vec,ops] = build_PopVec(d,unit_maps,ops)
%% Builds spike count population vector
%
% Intput:
%   d           d-struct
%   unit_maps   index of units to consider for population vector
%   ops         settings for construction
%       pre
%       post
%       binsize
%       sniff_align     sniff-alignment true or false
%       average_trial   indicating whether n consecutive trials should be
%                       averaged together. Value gives n consecutive trials to average (Default: 1)
%       smoothing       indicate if a moving-average smoothing should be
%                       performed on the spike counts vector. Value defines
%                       moving window size (Default: 0 == no smoothing)
%
% David Wolf 05/2020
%% Set options
if ~isfield(ops,'pre')
    ops.pre = 1;
end
if ~isfield(ops,'post')
    ops.post = 4;
end
if ~isfield(ops,'binsize')
    ops.binsize = .1;
end
% if ~isfield(ops,'baseline')
%     ops.baseline = [-1 0];
% end
if ~isfield(ops,'sniff_align')
    ops.sniff_align = 0;
end
if ~isfield(ops,'average_trials')
    ops.average_trials = 1;
end
if ~isfield(ops,'smoothing')
    ops.smoothing = 0;
end
if ~isfield(ops,'shuffle_trial_order')
    ops.shuffle_trial_order=0;
end
if ~isfield(ops,'align_to_event')
    ops.align_to_event='fv_on';
end

temp_ops = ops;
%% Compute population vector

% prepare timebase
time_base = -ops.pre:ops.binsize:ops.post;
time_base(end) = [];

% if smoothing is applied enlarge time-base to account for edges
if ops.smoothing > 0
    temp_ops.pre = ops.pre+ops.smoothing*ops.binsize;
    temp_ops.post = ops.post+ops.smoothing*ops.binsize;
%     time_base_smoothed = -ops.pre-ops.smoothing*ops.binsize:ops.binsize:ops.post+ops.smoothing*ops.binsize;
end

% get number of conditions
trialmatrix = d.events{1,1};
% conditions = unique([trialmatrix.case_num]);
conditions = unique([trialmatrix([trialmatrix.odor_dur]~=0).case_num]); %omit non-odor trials
num_conditions = numel(conditions);


pop_vec = cell(1,num_conditions);
%%% popVec is a 3D-matrix of dimensions: units x bins x trials
for cond = 1:size(pop_vec,2)
    pop_vec{1,cond} = zeros(numel(unit_maps),numel(time_base),floor(size(trialmatrix([trialmatrix.odor_dur]~=0),2)/num_conditions/ops.average_trials));
end

for ii = 1:size(pop_vec{1,1},1)
   
    % spikes for this unit
    spxtimes = d.spikes{1,(unit_maps(ii))};
    
    % trialtimes for the session of this unit
    events = d.events{1,d.map(unit_maps(ii))};
%     odor_num = unique([events.case_num]);
    odor_num = unique([events([events.odor_dur]~=0).case_num]); %omit non-odor trials

    
    for cond = 1:size(pop_vec,2)   
        % get spike count vecotr for this unit and condition
        trialtimes = [events([events.case_num]==odor_num(cond)).(ops.align_to_event)];
        [count_matrix,~,~] = get_psth_ba_zscore(spxtimes,trialtimes,temp_ops);
        
        % shuffle trial order within unit
        if ops.shuffle_trial_order
            shuffle_idx = randperm(size(count_matrix,1));
            count_matrix = count_matrix(shuffle_idx,:);
        end
        
        % smoothing with moving average
        if ops.smoothing > 0
           count_matrix = movmean(count_matrix,ops.smoothing,2);
           count_matrix = count_matrix(:,ops.smoothing+1:end-ops.smoothing);
        end
        
        % average over consecutive trials
        averaged_count_matrix = nan(size(pop_vec{1,cond},3),size(count_matrix,2));
        counter = 1;
        for tr = 1:size(averaged_count_matrix,1)
           averaged_count_matrix(tr,:) = mean(count_matrix(counter:counter+ops.average_trials-1,:),1); 
           counter = counter+ops.average_trials;
        end
        
        %parse to preallocated pop_vec
        pop_vec{1,cond}(ii,:,:) = averaged_count_matrix';
    end
end

end