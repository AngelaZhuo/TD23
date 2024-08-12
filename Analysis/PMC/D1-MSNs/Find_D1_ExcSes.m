%% Find D1-MSNs that significantly respond to manipulation compared to sham trials
% Only look at excitation sessions

ulog = UnitSelectionMod(d,"PmsnX(excite)");
uids = find(ulog);

for ux = 1:numel(uids)
    
    %Get spike, pulse and sham pulse time
    unit = uids(ux);
    spikes = d.spikes{unit};
    pulses = d.laser{d.map(unit)}{1}; %OptRed laser timestamps 
    sham_pulses = d.laser{d.map(unit)}{3};
    endevent = d.events{d.map(unit)}(end).fv_off_rewcue;
    pulses = pulses(pulses<endevent);
    sham_pulses = sham_pulses(sham_pulses<endevent);
    
    if length(pulses)>10 
        spikes = spikes(spikes>pulses(1) & spikes<(pulses(end)+1));
    else
        return;
    end
    
    %Create a big figure
    BigFig = figure('Position', [100, 100, 1600, 1200]);  % Adjust the size as needed
    t = tiledlayout(5, 4, 'TileSpacing', 'Compact', 'Padding', 'Compact');
    
    % Get the raster plot from pulse 1-10
    set(groot, 'DefaultFigureVisible',1)
    for px = 1:10
        pulse{px} = pulses(px:10:end);
        sham_pulse{px} = sham_pulses(px:10:end);
%         ps(px) = figure;
        %Fill the BigFig with subplots
        nexttile(t);
        for mx = 0:1
            if ~mx
                pulse_time = sham_pulse{px};
            [psth_sham{px}, trialspx_sham{px}, plotaxes_s] = mpsth_pj_x(spikes,pulse_time,'pre', 0, 'post',20 , 'binsz',...
                1, 'tb', 1, 'chart', 2,'fr',0,...
                'subplots',[2, 2,mx+3; 2, 2, mx+1]);
                title('sham')
            else
                pulse_time = pulse{px};
            [psth{px}, trialspx{px}, plotaxes_l] = mpsth_pj_x(spikes,pulse_time,'pre', 0, 'post',20 , 'binsz',...
                    1, 'tb', 1, 'chart', 2,'fr',0,...
                    'subplots',[2, 2,mx+3; 2, 2, mx+1]);
                title('laser')
            end
        end
        % Add a text label above the subplot
        annotation('textbox', 'Position', [0.5, 1.02, 0, 0] + [0, 0, 0, 0] + t.Children(end).Position, ...
           'String', "Pulse " + string(px), 'Units', 'normalized', 'FontSize', 12, ...
           'FontWeight', 'bold', 'Interpreter', 'none', 'HorizontalAlignment', 'center', ...
           'EdgeColor', 'none');
%         axes('Position', ps(px).Position.*[0 0 1 1], 'Box', 'off', 'Color', 'none', 'YColor', 'none', 'XColor', 'none');
%         text(0.5,1.02, "Pulse " + string(px),'Units','centimeter','FontSize',12,'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')
%         ps(px).Position = ps(px).Position + [0 0 0 0.5];
%         linkaxes(ps(px).Children([3 5]))
%         linkaxes(ps.Children([1 3]))
    end
%     cf = univCombFig(ps,[2 5],1);
end