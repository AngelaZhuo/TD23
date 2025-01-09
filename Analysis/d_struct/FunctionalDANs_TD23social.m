function c = FunctionalDANs_TD23social(d,c,uidx)
% Modified from FunctionalDANs_TD19.m to suit the social recognition head-fix exp.  
% freq range + phasic reward responsiveness
% AZ 2024.12.18

%% params
region = 3;  %VTA
fr_range = [1 12];
responsive = true;
evt_str = {'familiar','novel1','novel2'};
response_event = 'fv_on';
% pre_window = {[-1 0], [-1 0],[-0.5 0]};
% response_window ={[0 1], [0 1],[0 0.5]};
% post_window = {[1.2 2.2],[1.2 2.2],[0.5 1]};
pre_window = {[-1 0], [-1 0],[-1 0]};
response_window ={[0 1], [0 1],[0 1]};
post_window = {[1.2 2.2],[1.2 2.2],[1.2 2.2]};

binsize = 0.1;
stepsize = 0.025;

p_threshold = 0.05;

%%
regionunits = find([d.clust_params.region_coding]==region);
firingunits = find([d.clust_params.mean_fr]>fr_range(1) & [d.clust_params.mean_fr]<fr_range(2));

units = intersect(regionunits, firingunits);
units = intersect(units,uidx);

if isempty(units)
    for evt = 1:numel(evt_str)
        c.(['funcDAN_' evt_str{evt}])  = [];
    end
    return
end

umap = [d.map];
events = d.events;
spikes = d.spikes;
if any(umap==0)
    umap = ones(1,numel(umap));
end

for evt = 1:numel(evt_str)
    if responsive
       responseunits = units;
       for u=1:length(units)
           unit = units(u);
           session = umap(unit);
           if strcmp(evt_str{evt},'familiar')
               times = [events{session}([events{session}.odor_num]==9).(response_event)];
           elseif strcmp(evt_str{evt},'novel1')
               times = [events{session}.(response_event)];
               times = times([d.events{session}.odor_num]==10);
           elseif strcmp(evt_str{evt},'novel2')
               times = [events{session}.(response_event)];
               times = times([d.events{session}.odor_num]==8);
           end
           
           if length(times)>9
              spike_dist_pre = max(GetSpikeDist(spikes{unit}, times,SlidingTimes(stepsize, binsize,pre_window{evt}))');
              spike_dist_response = max(GetSpikeDist(spikes{unit}, times,SlidingTimes(stepsize, binsize, response_window{evt}))');
              spike_dist_post = max(GetSpikeDist(spikes{unit}, times, SlidingTimes(stepsize, binsize,post_window{evt}))');
              response(u) = signrank(spike_dist_response-spike_dist_pre)<p_threshold;
              dir(u) = mean(spike_dist_response-spike_dist_pre)>=0;
              phasic(u) = signrank(spike_dist_post-spike_dist_response)<p_threshold;
              dir_post(u) = mean(spike_dist_post-spike_dist_response)<=0;
           else
              response(u) = 0;
              phasic(u) = 0;
           end
       end
       responseunits(~response | ~phasic | ~dir | ~dir_post) = [];
    end
    
    c.(['funcDAN_' evt_str{evt}])  = responseunits;

end
end


function sliding_times = SlidingTimes(stepsize, binsize, window)
steps = (range(window)-binsize)/stepsize+1;

for sx=1:steps
    start = window(1)+(sx-1)*stepsize;
   sliding_times(sx,:) = [start start+binsize];

end

end

function [spike_dist, spike_dist_mean] = GetSpikeDist(spikes, times, timex)
% used by ActivityTraces
%

%%
for idx=1:size(times,2) % loop for all EVENTS transferred to function ...
    
    for jdx=1:size(timex,1) % loop for all INTERVALS ...
        spike_dist(idx,jdx)=sum(spikes>times(idx)+timex(jdx,1)&spikes<(times(idx)+timex(jdx,2)));
        %      spike_dist_mean(idx,jdx)=sum(spikes>times(idspikex)+timex(jdx,1)&spikes<(times(idx)+timex(jdx,2)));
        %      % used until  23.06.2020 -> commented out wondering why spike_dist =
        %      spike_dist_mean ?!!?!?
    end
    
    %     spike_dist_mean()
    
    
end

spike_dist_mean = mean(spike_dist);

end
