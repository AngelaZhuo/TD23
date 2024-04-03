% create trialmatrix
function [TM,Jitt] = getTM(d)
TM = NaN(numel(d.spikes),4,150);
Jitt = NaN(numel(d.spikes),1,150);
for sx = unique(d.map)
    events = d.events{sx};
    try
        TMs = [[events.curr_odorcue_odor_num]; [events.curr_rewardcue_odor_num];[events.drop_or_not];[events.inhibit_or_not]];
    catch
        try
            TMs = [[events.curr_odorcue_odor_num]; [events.curr_rewardcue_odor_num];[events.drop_or_not];[events.excite_or_not]];
        catch
            TMs = [[events.curr_odorcue_odor_num]; [events.curr_rewardcue_odor_num];[events.drop_or_not];zeros(size([events.drop_or_not]))];
        end
    end
    TMs(1,TMs(1,:)==10) = 6; % TD23 compatibility     
    
    try
        JittS = [events.jitter_OC_RC];
    catch
        JittS = NaN(1,numel(events));
    end
    for ux = find(d.map==sx)
        TM(ux,:,1:size(TMs,2)) = TMs;
        Jitt(ux,1,1:numel(JittS)) = JittS;
    end
    
end
end