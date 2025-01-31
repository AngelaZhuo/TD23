function d = doFuncDAN_TD23social(d)
% c = FunctionalDANs_TD19(d,[],1:numel(d.spikes));
c = FunctionalDANs_TD23social(d,[],1:numel(d.spikes));
if isempty(c)
    return
end
fn = fieldnames(c);
for i = 1:numel(fn)
    if ~isfield(d.clust_params,fn{i})
        d.clust_params(1).(fn{i}) = [];
    end
    
    if any(isempty([d.clust_params.(fn{i})]))
        for u = 1:numel(d.clust_params)
            if isempty(d.clust_params(u).(fn{i}))
                d.clust_params(u).(fn{i}) = 0;
            end
        end
    end
    
    for u = 1:numel(d.spikes)
        if ismember(u,c.(fn{i}))
            d.clust_params(u).(fn{i}) = true;
        else
            d.clust_params(u).(fn{i}) = false;
        end
    end
end

end