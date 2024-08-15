%% Find D1-MSNs that significantly respond to manipulation compared to sham trials
% Only look at excitation sessions
% Within 20ms after each pulse -- Looking for tagged response

clearvars -except d
ulog = UnitSelectionMod(d,"PmsnX(excite)");
uids = find(ulog);
lresp = getUnitsTagResponseTD23(d,uids);
uids = uids(lresp==1);
set(groot, 'DefaultFigureVisible',0);


for ux = 1:numel(uids)
    
    %Get spike, pulse and sham pulse time
    unit = uids(ux);
    spikes = d.spikes{unit};
    X = d.info(d.map(unit)).tag;
    events = d.events{d.map(unit)};

    % Paradigm selection: determine what to look for
    switch X
        case {'exciteA','exciteA_sham'}
        stimTrials = ismember([events.curr_trialtype],1:4); %Take only A-trials
        manip = [events(stimTrials).excite_or_not];
        case {'exciteB','exciteB_Sham'}
        stimTrials = ismember([events.curr_trialtype],5:8);  %Take only B-trials  
        manip = [events(stimTrials).excite_or_not];
    end
    
    pulses = d.laser{d.map(unit)}{1}; %OptRed LED timestamps 
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
        
    if length(pulses)>10 
        spikes = spikes(spikes>pulses(1) & spikes<(pulses(end)+1));
    else
        return;
    end
    
    %Create a big figure
    BigFig = figure('Position', [1, 1, 60, 30],'Units','centimeter');  % Adjust the size as needed
    t = tiledlayout(5, 8, 'TileSpacing', 'Compact', 'Padding', 'Compact');
    
    % Get the raster plot from pulse 1-10
    for px = 1:10
%         pulse{px} = pulses(px:10:end);
%         sham_pulse{px} = sham_pulses(px:10:end);
        pulse = All_pulses_stim(px:10:end);
%         ps(px) = figure;
        %Fill the BigFig with subplots
        for mx = 0:1
            trials = find(manip==mx);
            pulse_time = pulse(trials);
            if ~mx
            [psth_sham{px}, trialspx_sham{px}] = mpsth_az(spikes,pulse_time,'pre', 0, 'post',20 , 'binsz',...
                1, 'tb', 1, 'chart', 2,'fr',1);
                title("sham pulse" + px)
            else
            [psth{px}, trialspx{px}] = mpsth_az(spikes,pulse_time,'pre', 0, 'post',20 , 'binsz',...
                    1, 'tb', 1, 'chart', 2,'fr',1);
                title("laser pulse" + px)
            end
        end
        % Add a text label above the subplot
        % axes('Position', t.Children(10).Position.*[0 0 1 1], 'Box', 'off', 'Color', 'none', 'YColor', 'none', 'XColor', 'none');
        % text(0.5,1.02, "Pulse " + string(px),'Units','centimeter','FontSize',12,'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')
%         ps(px).Position = ps(px).Position + [0 0 0 0.5];
%         linkaxes(ps(px).Children([3 5]))
    end
    sgtitle("Unit_" + unit,'Interpreter','none')
    linkaxes(t.Children(2:2:end))
    saveas(gcf,"/zi-flstorage/data/Angela/DATA/TD23/Plots/UnitInfo/d1_tag_prob/manip_pulse_20ms/ShamVSLaser_Unit" + unit + ".png",'png')
%     cf = univCombFig(ps,[2 5],1);
end

%% Get probability of firing for each bin - sham vs. laser
% 20ms following each pulse 
% Across pulses and across units

for ux = 1:numel(uids)

    %Get spike, pulse and sham pulse time
    unit = uids(ux);
    spikes = d.spikes{unit};
    X = d.info(d.map(unit)).tag;
    events = d.events{d.map(unit)};

    % Paradigm selection: determine what to look for
    switch X
        case {'exciteA','exciteA_sham'}
        stimTrials = ismember([events.curr_trialtype],1:4); %Take only A-trials
        manip = [events(stimTrials).excite_or_not];
        case {'exciteB','exciteB_Sham'}
        stimTrials = ismember([events.curr_trialtype],5:8);  %Take only B-trials  
        manip = [events(stimTrials).excite_or_not];
    end
    
    pulses = d.laser{d.map(unit)}{1}; %OptRed LED timestamps 
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
        
    if length(pulses)>10 
        spikes = spikes(spikes>pulses(1) & spikes<(pulses(end)+1));
    else
        return;
    end
    
    for mx = 0:1
        trials = find(manip==mx);
        pulse_time = [];
        for trx =1:numel(trials)
            pulse_trial = All_pulses_stim((trials(trx)-1)*10+1 : trials(trx)*10);
            pulse_time = [pulse_time;pulse_trial];
        end
        [psth_sham, trialspx_sham] = mpsth_az(spikes,pulse_time,'pre', 0, 'post',20 , 'binsz',...
            1, 'tb', 1, 'chart', 0,'fr',0);
    end
    
end
