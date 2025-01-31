function [euclidian, cosine] = compute_popVec_distance_between_condition(pop_vec,ops)
%% Computes Population Vector for response window between conditions
%
% Response window population vector: counts spikes in response window
%
% Output:
%   euclidian/cosine distance between conditions. Upper triangle spike
%   count, lower triangle normalized spike count
%%

if ~isfield(ops,'response')
    ops.response = [0 1];
end

% prepare timebase
time_base = -ops.pre:ops.binsize:ops.post;
time_base(end) = [];
% 
% % get baseline bins
% baseline_bins = find(ops.baseline(1)==time_base):find(ops.baseline(2)==time_base)-1;

% get response window bins
response_bins = find(ops.response(1)==time_base):find(ops.response(2)==time_base)-1;


% buid response vector 
resp_vector = cell(1,size(pop_vec,2));
for ii = 1:size(pop_vec,2)
   for tr = 1:size(pop_vec{1,ii},3)
       resp_vector{1,ii}(:,tr) = sum(pop_vec{1,ii}(:,response_bins,tr),2); %units x trials
   end
end

euclidian = cell(size(pop_vec,2),size(pop_vec,2));
cosine = cell(size(pop_vec,2),size(pop_vec,2));

% distance between trials
for ii = 1:size(pop_vec,2) %conditions
    for jj = 1:size(pop_vec,2) %conditions
        euclidian{ii,jj} = nan(size(pop_vec{1,ii},3),size(pop_vec{1,ii},3));
        cosine{ii,jj} = nan(size(pop_vec{1,ii},3),size(pop_vec{1,ii},3));
        for tri = 1:size(pop_vec{1,ii},3) %trials
            for trj = 1:size(pop_vec{1,ii},3) %trials

                % euclidian distance: lower triangle is normalized
                if ii<jj
                    euclidian{ii,jj}(tri,trj) = pdist2(resp_vector{1,ii}(:,tri)',resp_vector{1,jj}(:,trj)');
                elseif ii==jj %diagonal = within-odor distance
                    if tri<=trj
                        euclidian{ii,jj}(tri,trj) = pdist2(resp_vector{1,ii}(:,tri)',resp_vector{1,jj}(:,trj)');
                    else
%                         euclidian{ii,jj}(tri,trj) = pdist2(resp_vector{2,ii}(:,tri)',resp_vector{2,jj}(:,trj)');
                    end
                else
%                     euclidian{ii,jj}(tri,trj) = pdist2(resp_vector{2,ii}(:,tri)',resp_vector{2,jj}(:,trj)');
                end
                % cosine distance
                if ii<=jj
                    cosine{ii,jj}(tri,trj) = pdist2(resp_vector{1,ii}(:,tri)',resp_vector{1,jj}(:,trj)','cosine');
                elseif ii==jj %diagonal = within-odor distance
                    if tri<=trj
                        euclidian{ii,jj}(tri,trj) = pdist2(resp_vector{1,ii}(:,tri)',resp_vector{1,jj}(:,trj)');
                    else
%                         euclidian{ii,jj}(tri,trj) = pdist2(resp_vector{2,ii}(:,tri)',resp_vector{2,jj}(:,trj)');
                    end
                else
%                     cosine{ii,jj}(tri,trj) = pdist2(resp_vector{2,ii}(:,tri)',resp_vector{2,jj}(:,trj)','cosine');
                end
            end
        end
    end
end

end