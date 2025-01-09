function [condition_cell, time_base] = compute_all_psth(d, unit_maps, ops)

% Set options
if ~isfield(ops,'pre')
    ops.pre = 1;
end
if ~isfield(ops,'post')
    ops.post = 4;
end
if ~isfield(ops,'binsize')
    ops.binsize = .05;
end
if ~isfield(ops,'baseline')
    ops.baseline = [-1 0];
end
if ~isfield(ops,'sniff_align')
    ops.sniff_align = 0;
end
if ~isfield(ops,'lfp_align')
    ops.lfp_align = 0;
end
if ~isfield(ops,'trial_subselect')
    ops.trial_subselect = 0;
end

%% Compute
% prepare timebase
time_base = -ops.pre:ops.binsize:ops.post;
time_base(end) = [];

% get number of conditions
trialmatrix = d.events{1,1};
conditions = unique([trialmatrix([trialmatrix.odor_dur]~=0).case_num]); %omit non-odor trials
num_conditions = numel(conditions);

% preallocate image-matrix
condition_cell = cell(1, num_conditions);
for cond = 1:size(condition_cell,2)
    condition_cell{1,cond} = zeros(numel(unit_maps),numel(time_base));
end

%%% get all zscores for condition
for ii=1:numel(unit_maps)
    % spikes for this unit
    spxtimes = d.spikes{1,(unit_maps(ii))};
    
    % trialtimes for the session of this unit
    events = d.events{1,d.map(unit_maps(ii))};
%     odor_num = unique([events.case_num]);
    
    for cond = 1:size(condition_cell,2)   
        % get zscore for this unit and condition
        trialtimes = [events([events.case_num]==conditions(cond)).fv_on];
        if ops.lfp_align
            if isfield(events,'lfp_shift')
                trialtimes = trialtimes + [events([events.case_num]==conditions(cond)).lfp_shift];
            end
        end
        
        if ops.trial_subselect
            switch ops.trial_subselect
                case 'first five'
                    trialtimes = trialtimes(1:5);
                case 'last five'
                    trialtimes = trialtimes(end-4:end);
                case 'cut 1-5'
                    trialtimes = trialtimes(6:end);
                case 'cut 1-3'
                    trialtimes = trialtimes(4:end);
            end
        end
        [~,curr_psth,~] = get_psth_ba_zscore(spxtimes,trialtimes,ops);
        
        %parse to preallocated image matrix
        condition_cell{1,cond}(ii,:) = curr_psth;
    end
end
