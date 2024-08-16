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
    if strcmp(X,'exciteA')
        stimTrials = ismember([events.curr_trialtype],1:4);
        manip = [events(stimTrials).excite_or_not];
    elseif strcmp(X, 'exciteB')
        stimTrials = ismember([events.curr_trialtype],5:8);
        manip = [events(stimTrials).excite_or_not];
    else
        continue;
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

clearvars -except d uids

PSTH_sham = [];
PSTH_laser = [];
TrialSpx_sham = [];
TrialSpx_laser = [];

for ux = 1:numel(uids)

    %Get spike, pulse and sham pulse time
    unit = uids(ux);
    spikes = d.spikes{unit};
    X = d.info(d.map(unit)).tag;
    events = d.events{d.map(unit)};

    % Paradigm selection: determine what to look for
    if strcmp(X,'exciteA')
        stimTrials = ismember([events.curr_trialtype],1:4);
        manip = [events(stimTrials).excite_or_not];
    elseif strcmp(X, 'exciteB')
        stimTrials = ismember([events.curr_trialtype],5:8);
        manip = [events(stimTrials).excite_or_not];
    else
        continue;
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
        [psth{mx+1}, trialspx{mx+1}] = mpsth_az(spikes,pulse_time,'pre', 0, 'post',20 , 'binsz',...
            1, 'tb', 1, 'chart', 0,'fr',0);
    end
    
    % Remove units with no spike in either sham or laser delays
%     if sum(psth{1}(:,2))== 0 || sum(psth{2}(:,2)) == 0
%         continue;
%     end
    
    % Plot FR probability of each bin of one unit
    unit_P_FR_sham = (psth{1}(:,2))/(numel(find(manip==0))*10)*100;
    unit_P_FR_laser = (psth{2}(:,2))/(numel(find(manip==1))*10)*100;
    
%     figure('Position', [1, 1, 20, 10],'Units','centimeter')
%     t = tiledlayout(1,2);
%     
%     nexttile
%     bar(psth{1}(:,1)+1, unit_P_FR_sham,'k','BarWidth',1)
%     title('sham')
%     ylabel('Probability (%)','FontSize',8)
%     xlabel('Bin (1ms)','FontSize',8)
%     
%     nexttile
%     bar(psth{2}(:,1)+1, unit_P_FR_laser,'k','BarWidth',1)
%     title('laser')
%     ylabel('Probability (%)','FontSize',8)
%     xlabel('Bin (1ms)','FontSize',8)
%     
%     sgtitle("P(spike)_perBin_Unit_" + unit,'Interpreter','none')
%     linkaxes(t.Children(1:2))
    
%     saveas(gcf,"/zi-flstorage/data/Angela/DATA/TD23/Plots/UnitInfo/d1_tag_prob/manip_pulse_P(spike)/P(spike)_Unit" + unit + ".png",'png')
    
    PSTH_sham = [PSTH_sham, psth{1}(:,2)];
    PSTH_laser = [PSTH_laser, psth{2}(:,2)];
    TrialSpx_sham = [TrialSpx_sham, trialspx{1}];
    TrialSpx_laser = [TrialSpx_laser, trialspx{2}];

end

% Plot FR probability of each bin of all units
P_FR_sham = sum(PSTH_sham,2)/(size(TrialSpx_sham,1)*size(TrialSpx_sham,2))*100;
P_FR_laser = sum(PSTH_laser,2)/(size(TrialSpx_laser,1)*size(TrialSpx_laser,2))*100;

figure('Position', [1, 1, 20, 10],'Units','centimeter')
t = tiledlayout(1,2);

nexttile
bar(psth{1}(:,1)+1, P_FR_sham,'k','BarWidth',1)
title('sham')
ylabel('Probability (%)','FontSize',8)
xlabel('Bin (1ms)','FontSize',8)

nexttile
bar(psth{2}(:,1)+1, P_FR_laser,'k','BarWidth',1)
title('laser')
ylabel('Probability (%)','FontSize',8)
xlabel('Bin (1ms)','FontSize',8)


sgtitle("P(spike)_perBin_AllUnits" ,'Interpreter','none')
linkaxes(t.Children(1:2))

saveas(gcf,"/zi-flstorage/data/Angela/DATA/TD23/Plots/UnitInfo/d1_tag_prob/manip_pulse_P(spike)/P(spike)_AllUnits.png",'png')

%% PSTH of the these units

clearvars -except d uids

tag = {d.info(d.map(uids)).tag};

uids_exciteB = uids(strcmp(tag,'exciteB'));
uids_exciteA = uids(strcmp(tag,'exciteA'));

psf=PSTHfromiFR(d,iFR,uids_exciteB,TM,'manipulation',{0 1});
psf1=PSTHfromiFR(d,iFR,uids_exciteA,TM,'manipulation',{0 1});

saveas(psf1,"/zi-flstorage/data/Angela/DATA/TD23/Plots/UnitInfo/d1_tag_prob/PSTH_manip_pulse/iFR_PSTH_ExciteA.png",'png')
