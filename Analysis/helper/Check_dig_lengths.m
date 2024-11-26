%% 160-trial reappraisal session
%load digital.mat and protocol files
% channel 1 is fv, channel 2 is puff
dchan  = dchannels(1:30:end,:);
fv_off = find(diff(dchan(:,2))==-1)/1000;
fv_on = find(diff(dchan(:,2))==1)/1000;
fv_dist = [0;diff(fv_on)];
fv_on(161) = 1;
fv_dist_onoff = fv_on(2:161) - fv_off;

puff_on = find(diff(dchan(:,1))==1)/1000;

puff_idx = find([session.trialmatrix.air_lat]>0);
clc
odor_puff_dist = [];
for pi = 1:numel(puff_idx)
    odor_puff_dist_cur = puff_on(pi)- fv_off(puff_idx(pi));
    odor_puff_dist = [odor_puff_dist;odor_puff_dist_cur];
end

%% 120-trial reappraisal session

%load digital.mat and protocol files
% channel 1 is fv, channel 2 is puff
dchan  = dchannels(1:30:end,:);
fv_off = find(diff(dchan(:,2))==-1)/1000;
fv_on = find(diff(dchan(:,2))==1)/1000;
fv_dist = [0;diff(fv_on)];
fv_on(121) = 1;
fv_dist_onoff = fv_on(2:121) - fv_off;

puff_on = find(diff(dchan(:,1))==1)/1000;

puff_idx = find([session.trialmatrix.air_lat]>0);

odor_puff_dist = [];
for pi = 1:numel(puff_idx)
    odor_puff_dist_cur = puff_on(pi)- fv_off(puff_idx(pi));
    odor_puff_dist = [odor_puff_dist;odor_puff_dist_cur];
end

