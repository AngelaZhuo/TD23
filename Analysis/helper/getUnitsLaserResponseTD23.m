%% test response to laser in TD23 manipulation experiments
%% input
% - d struct
% - uids: vector with unit IDs
%% output
% - lresp: -1 inhibited, 0 not modulated, 1 excited

function lresp = getUnitsLaserResponseTD23(d,uids)

[sids,~,sUnits] = unique(d.map(uids));
binsize = .1;
lresp = NaN(numel(uids),1);
p_thresh = .05;

% loop sessions
for sx = 1:numel(sids)
    X = d.info(sids(sx)).tag;
    events = d.events{1,sids(sx)};
    % Paradigm selection: determine what to look for
    switch X
        case {'CS1_silence','CS1_silence_sham'}
            stimWin = [[events.fv_on_odorcue];[events.fv_on_odorcue]+1.2];
            manip = [events.inhibit_or_not];
        case {'CS1delay_silence','CS1delay_silence_sham'}
            stimWin = [[events.fv_off_odorcue];[events.fv_off_odorcue]+1.2];
            manip = [events.inhibit_or_not];
        case {'CS2_silence','CS2_silence_sham'}
            stimWin = [[events.fv_on_rewcue];[events.fv_on_rewcue]+1.2];
            manip = [events.inhibit_or_not];            
        case {'CS2delay_silence','CS2delay_silence_sham'}
            stimWin = [[events.fv_off_rewcue];[events.fv_off_rewcue]+1.2];
            manip = [events.inhibit_or_not];            
        case {'exciteA','exciteA_sham'}
            stimTrials = ismember([events.curr_trialtype],1:4);
            stimWin = [[events(stimTrials).fv_on_odorcue];[events(stimTrials).fv_on_odorcue]+.6];
            manip = [events(stimTrials).excite_or_not];
        case {'exciteB','exciteB_Sham'}
            stimTrials = ismember([events.curr_trialtype],5:8);
            stimWin = [[events(stimTrials).fv_on_odorcue];[events(stimTrials).fv_on_odorcue]+.6];
            manip = [events(stimTrials).excite_or_not];
    end
    
    % Compare unit wise response laser vs sham using signrank
    for ux = find(sUnits==sx)'
        spikes = d.spikes{uids(ux)};        
        for mx = 0:1
            trials = find(manip==mx);
            tmpSpikeDist{mx+1} = NaN(numel(trials),round(diff(stimWin(:,1))/binsize));
            for trx = 1:numel(trials)
                timex = stimWin(1,trials(trx)):binsize:stimWin(2,trials(trx));
                for tx = 1:numel(timex)-1
                    tmpSpikeDist{mx+1}(trx,tx) = sum(spikes>timex(tx)&spikes<=timex(tx+1));
                end
            end            
        end
        
        % assign units resp 
        if signrank(mean(tmpSpikeDist{1},1),mean(tmpSpikeDist{2},1))<p_thresh
           if mean(mean(mean(tmpSpikeDist{2},1)-tmpSpikeDist{1},1))>0
               lresp(ux) = 1;
           else
               lresp(ux) = -1;
           end
        else
           lresp(ux) = 0; 
        end
        
    end
    
    
end
breakpoint ='here';