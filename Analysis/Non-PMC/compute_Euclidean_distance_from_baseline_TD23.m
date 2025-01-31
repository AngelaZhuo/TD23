function dist = compute_Euclidean_distance_from_baseline_TD23(pop_vec,ops)
%% Euclidean distance from baseline
% Input:
%    pop_vec: cell with n conditions
%       each cell contains a the population vector for a condition: units x
%       timebins x trials
% Output:
%   dist ist the Euclidean distance from baseline

% Modified from compute_Euclidean_distance_from_baseline.m (OXT-Wolf), 20250124 AZ 

% find baseline bins

if ~isfield(ops,'baseline')
    ops.baseline = [-1 0];
end

% prepare timebase
time_base = -ops.pre:ops.binsize:ops.post;
time_base(end) = [];

baseline_bins = find(ops.baseline(1)==time_base):find(ops.baseline(2)==time_base)-1;

% create mean baseline population vector for every trial
base_vector = cell(size(pop_vec,1),size(pop_vec,2));
cum_base_vector = [];
for ii = 1:size(base_vector,2)
   base_vector{1,ii} = squeeze(mean(pop_vec{1,ii}(:,baseline_bins,:),2)); 
   
   % cumulative baseline-vector over all conditions
    cum_base_vector = [cum_base_vector, base_vector{1,ii}];
end

% average over cumulative baseline vector
average_base_vector = mean(cum_base_vector,2);

% initialize output
dist = cell(1,size(pop_vec,2));

% distance to baseline for every trial and every bin
for ii = 1:size(pop_vec,2)
    for tr = 1:size(pop_vec{1,ii},3)
        for bin = 1:size(pop_vec{1,ii},2)
            dist{1,ii}(tr,bin) = pdist2(pop_vec{1,ii}(:,bin,tr)',average_base_vector')./sqrt(length(pop_vec{1,ii}(:,bin,tr)')); %divided by the sqaure root of the number of units
        end
    end
end
end