%% test response to laser in TD23 manipulation experiments
% Use bootstrap to determine if the unit laser response was significantly different from sham response 
% Compare 600ms window after fv_on between manip and sham trials
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
    
    % Compare unit wise response laser vs sham using bootstrap
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
        
%         % assign units resp 
%         if
%         ttest2(mean(tmpSpikeDist{1},1),mean(tmpSpikeDist{2},1))<p_thresh   % You lose a lot of statistical power by discarding the trials and doing a paired test between only bins!!!! imagine, 50 or so data points againt 12 :S         %
%            if mean(mean(mean(tmpSpikeDist{2},1)-tmpSpikeDist{1},1))>0
%                lresp(ux) = 1;
%            else
%                lresp(ux) = -1;
%            end
%         else
%            lresp(ux) = 0; 
%         end
        nboot = 10000;
        Sham = mean(tmpSpikeDist{1},2);
        Laser = mean(tmpSpikeDist{2},2);
        Delta = mean(Laser)-mean(Sham);
        Aller = [Sham; Laser];
        Sham_bst = NaN(size(Sham,1),1);
        Laser_bst =  NaN(size(Laser,1),1);
        Delta_bst = NaN(nboot,1);
        for bst = 1:nboot
            Idx = randperm(numel(Aller));
            Sham_bst(:) = Aller(Idx(1:numel(Sham_bst)));
            Laser_bst(:) =  Aller(Idx(numel(Sham_bst)+1:end));
            Delta_bst(bst) = mean(Laser_bst)-mean(Sham_bst);
        end
        if Delta>0
            p = 2.*mean(Delta_bst>Delta);
            if p<p_thresh
                lresp(ux) = 1;
            end
        elseif Delta<0
            p = 2.*mean(Delta_bst<Delta);
            if p<p_thresh
                lresp(ux) = -1;
            end
        else
            p = 1;
            if p<p_thresh
                lresp(ux) = 0;
            end
        end
            
    end
    
    
end