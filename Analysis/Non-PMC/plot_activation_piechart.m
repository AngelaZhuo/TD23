function [f1,ops, excited, inhibited] = plot_activation_piechart(d,unit_maps,ops)

%% Set options
if ~isfield(ops,'pre')
    ops.pre = 1;
end
if ~isfield(ops,'post')
    ops.post = 4;
end
if ~isfield(ops,'binsize')
    ops.binsize = .05;
end
if ~isfield(ops,'baseline')
    ops.baseline = [-1 0];
end
if ~isfield(ops,'sniff_align')
    ops.sniff_align = 0;
end
if ~isfield(ops,'activation_threshold')
    ops.activation_threshold = 1.96;
end
if ~isfield(ops,'Colormap')
    ops.Colormap = colormap;
    ops.Colormap = ops.Colormap(1:3,:);
end

%% Compute image

% prepare timebase
time_base = -ops.pre:ops.binsize:ops.post;
time_base(end) = [];

% get number of conditions
trialmatrix = d.events{1,1};
conditions = unique([trialmatrix([trialmatrix.odor_dur]~=0).case_num]); %omit non-odor trials
num_conditions = numel(conditions);

% preallocate zscore-matrix
condition_cell = cell(1,num_conditions);
for cond = 1:size(condition_cell,2)
    condition_cell{1,cond} = zeros(numel(unit_maps),numel(time_base));
end

%%% get all zscores for condition
for ii=1:numel(unit_maps)
    % spikes for this unit
    spxtimes = d.spikes{1,(unit_maps(ii))};
    
    % trialtimes for the session of this unit
    events = d.events{1,d.map(unit_maps(ii))};
    odor_num = unique([events([events.odor_dur]~=0).case_num]);
    
    for cond = 1:size(condition_cell,2)   
        % get zscore for this unit and condition
        trialtimes = [events([events.case_num]==odor_num(cond)).fv_on];
        [~,~,curr_zscore] = get_psth_ba_zscore(spxtimes,trialtimes,ops);
        
        %parse to preallocated image matrix
        condition_cell{1,cond}(ii,:) = curr_zscore;
    end
end

%% Plot

f1 = figure('name','Fraction activated');
set(f1,'Position',[615.8966 609.2759 1.2546e+03 357.5172])
% fullscreen(f1);


response_bins = find(time_base==0):find(time_base==1)-1;
for cond = 1:size(condition_cell,2)
    
   s(cond) = subplot(1,size(condition_cell,2),cond); 
   excited(cond) = nnz(ops.activation_threshold < mean(condition_cell{1,cond}(:,response_bins),2));
   inhibited(cond) = nnz(-ops.activation_threshold > mean(condition_cell{1,cond}(:,response_bins),2));
   
   pie([numel(unit_maps)-excited(cond)-inhibited(cond),excited(cond),inhibited(cond)]);
   s(cond).Colormap = ops.Colormap; 
   title(get_event_label_TD23(odor_num(cond)),'FontSize',16);
%    set_fonts();
end

legend1=legend('no response','excited','inhibited');
set(legend1,...
    'Position',[0.351601522944304 0.157560841522822 0.290990000474219 0.0581120927655652],...
    'Orientation','horizontal',...
    'FontSize',8);

end
