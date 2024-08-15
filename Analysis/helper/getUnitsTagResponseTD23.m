%% Test response within 20ms to each led pulse during manipulation period
% Modified from getUnitsLaserResponseTD23.m
% Focus on 20ms window after each pulse
%% input
% - d struct
% - uids: vector with unit IDs
%% output
% - lresp: -1 inhibited, 0 not modulated, 1 excited

function lresp = getUnitsTagResponseTD23(d,uids)

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
        case {'exciteA','exciteA_sham'}
        stimTrials = ismember([events.curr_trialtype],1:4);
        manip = [events(stimTrials).excite_or_not];
        case {'exciteB','exciteB_Sham'}
        stimTrials = ismember([events.curr_trialtype],5:8);
        manip = [events(stimTrials).excite_or_not];
    end


    
    % Compare unit wise response laser vs sham using bootstrap
    for ux = find(sUnits==sx)'
        unit = uids(ux);
        spikes = d.spikes{unit};
        pulses = d.laser{d.map(unit)}{1};
        sham_pulses = d.laser{d.map(unit)}{3};
        endevent = d.events{d.map(unit)}(end).fv_off_rewcue;
        pulses = pulses(pulses<endevent);
        sham_pulses = sham_pulses(sham_pulses<endevent);
        All_pulses = sort([pulses;sham_pulses]);
        stimPulses = false(1, length(All_pulses));
        % Select pulses that are from stim trials
        for i = 1:length(stimTrials)
            if stimTrials(i)
                % If stimTrials(i) is true, set the corresponding All_pulses values to true
                stimPulses((i-1)*10 + 1 : i*10) = true;
            end
        end
        All_pulses_stim = All_pulses(stimPulses)+0.01;  %Add 10ms pulse duration

        for mx = 0:1
            trials = find(manip==mx);
            tmpSpikeDist{mx+1} = NaN(numel(trials),10);
            for trx = 1:numel(trials)
                timex = All_pulses_stim((trials(trx)-1)*10+1 : trials(trx)*10);
                for tx = 1:numel(timex)
                    tmpSpikeDist{mx+1}(trx,tx) = sum(spikes>timex(tx)&spikes<=timex(tx)+0.02);
                end
            end            
        end
        
        rng('shuffle')
        nboot = 10000;
        Sham = tmpSpikeDist{1}(:);
        Laser = tmpSpikeDist{2}(:);
        Delta = mean(Laser)-mean(Sham);
        Aller = [Sham; Laser];
        Delta_bst = NaN(nboot,1);
        parfor bst = 1:nboot
            Sham_bst = NaN(size(Sham,1),1);
            Laser_bst =  NaN(size(Laser,1),1);            
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

end
