function [crosstag_ex,crossinfo,fex] = XcorrExcite(d,unit,plot)
%load d-sturct and iFR, get the unit from UnitSelectionMod.m
% Modified from CrossTagTD23 to get the cross-correlogram of excited units from the LED-excitation during session
fex = [];
crosstag_ex = 0;
crossinfo.border95 = nan;
crossinfo.border99 = nan;
crossinfo.corrgram = nan;

unitregion = d.clust_params(unit).region_coding;
if unitregion == 2  %OT
    color_idx = [3 5 3 1];
elseif unitregion == 1  %NAcc
    color_idx = [0 6 1 2];
elseif unitregion == 3  %VTA
    return
end

if plot
colors = GetColorShades(GetColorScheme('NYC', color_idx(1)), color_idx(2), color_idx(3:4));
end

opacity = 1;
consec_bins =2;
binwidth = 1; %ms
lag = 20; %#

lagt=(lag*binwidth)/1000; %in seconds
binwidtht=round(1000/binwidth);

spikes = d.spikes{unit};
pulses = d.laser{d.map(unit)}{1}; %OptRed laser timestamps 
%pulses = d.laser{d.map(unit)}{region}; Mirko had tagging in diff. regions
if ~isempty(d.events{d.map(unit)})
    endevent = d.events{d.map(unit)}(end).fv_off_rewcue;
else
    endevent = 0;
end

pulses = pulses(pulses<endevent); %only laserpulses before session ended
pulses = pulses(diff(pulses)>(lag-1)/1000); % only laserpulses with a delay of more than lag ms after last pulse

if length(pulses)>10 
    spikes = spikes(spikes>pulses(1) & spikes<(pulses(end)+1));
else
  return;
end

% real cross corr.

if length(spikes)>25
  crosscr = pxcorr(spikes, pulses, binwidtht, lagt);

%% control cross corrs
%create 1000 randomized shifted laser pulse time and take their spike cross-correlations 
    for i=1:1000
      curr_dithers = rand(1, length(pulses))*lagt*3;
      xc = pulses + curr_dithers';
      xc = xc - lagt*1.5;
      xc = sort(xc);
      controlcr(i,:) = pxcorr(spikes, xc, binwidtht, lagt);
    end

%% global or local extrema?

    % using local extrema
    prct1=prctile(controlcr,[0.5 99.5]);

    prct5=prctile(controlcr,[2.5 97.5]);

    % using global extrema (just one distribution for all bins)?

    prct5=prctile(controlcr(:),[2.5 97.5])';
    prct5=repmat(prct5, [1 lag*2+1]);

%%
    if plot
    fex = figure;
      hold on
    xidx=-lag*binwidth:binwidth:lag*binwidth;
    % stairs(xidx, crosscr, 'Color', colors(region,:), 'LineWidth', 1.5)

    plothandles(1) = bar(xidx, crosscr./length(pulses),'BarWidth', 1, 'FaceColor', [0 0.4470 0.7410], 'EdgeColor', 'none', 'FaceAlpha', opacity);

%     xlim([xidx(1) xidx(end)]);
    hold on
    plothandles(2) = stairs(xidx,prct5(1,:)./length(pulses), '--', 'Color', colors(unitregion,:), 'LineWidth', 0.75);
    plothandles(3) = stairs(xidx,prct5(2,:)./length(pulses), '--', 'Color', colors(unitregion,:), 'LineWidth', 0.75);


    xlabel('Time from laser pulse (ms)','FontSize',12)
    ylabel('spikes per laser pulse','FontSize',12)
    xlim([0 lag])

%     yts = yticks;

    PlotFormat();
    % yticks(yts(1:2:end))

    end
    
%% Find crosstag
    crosscr = crosscr(floor(length(crosscr)/2):end); % only looking for spike following laserpulse
    prct5 = prct5(:, floor(length(prct5)/2):end);
    prct1 = prct1(:, floor(length(prct1)/2):end);

    signif_bins = crosscr>=prct5(2,:);
    v = cumsum(crosscr>prct5(2,:));
    x = [0 cumsum(diff(v)~=1)];
    p = length(v(x==mode(x)))-1;
    higher = double(p>=consec_bins);


    v = cumsum(crosscr<prct5(1,:));
    x = [0 cumsum(diff(v)~=1)];
    p = length(v(x==mode(x)))-1;
    lower = double(p>=consec_bins);

    if higher && ~lower
      crosstag_ex = 1;
    elseif ~higher && lower
    crosstag_ex = 2;
    elseif higher && lower
      crosstag_ex = 3;
    end
    
    if plot
%        title(['Unit',num2str(unit),'_tetrode',num2str(d.clust_params(unit).tetrode),'_crosstag',num2str(crosstag)],'Interpreter','none','FontSize',10)
       title(['Exicte_','Unit',num2str(unit),'_crosstag',num2str(crosstag_ex)],'Interpreter','none','FontSize',10)
    end
    
    crossinfo.corrgram = crosscr;
    crossinfo.border95 = prct5;
    crossinfo.border99 = prct1;

end


end