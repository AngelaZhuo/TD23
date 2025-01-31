function [binned_array, psth, zscore] = get_psth_ba_zscore(spxtimes,trialtimes,ops)
%% This function computes a binned array, psth and response zscore 
% inputs all in seconds
%
% David Wolf, 05/2020
%% Set defaults if nothing specified in options "ops"
if ~isfield(ops,'pre')
    ops.pre = 1; %s
end
if ~isfield(ops,'post')
    ops.post = 4; %s
end
if ~isfield(ops,'binsize')
    ops.binsize = .05; %s
end
if ~isfield(ops,'baseline')
    ops.baseline = [-1 0]; %s
end
if ~isfield(ops,'sniff_align')
    ops.sniff_align = 0;
end


pre = ops.pre;
post = ops.post;
binsize = ops.binsize;

%% compute
%%% preallocate PSTH. trials x time matrix
time_base = -pre:binsize:post; 
time_base = round(time_base,10); %Fix floating-point problem
binned_array = zeros(numel(trialtimes),numel(time_base)-1);

%%% loop over trials and count spikes in bin
for tr = 1:numel(trialtimes)
    trial_spx = spxtimes-trialtimes(tr);
    binned_array(tr,:) = histcounts(trial_spx,time_base);
end

psth = mean(binned_array./binsize);

baseline_bins = find(time_base==ops.baseline(1)):find(time_base==ops.baseline(2))-1;
zscore = (psth-mean(psth(baseline_bins)))./std(psth(baseline_bins));

end