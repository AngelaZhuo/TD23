%% Main script for plotting individual unit info
%Modified from analysis_familiar1.m (OFC-AI cohort)
% AZ 2024.12.18

clear
load('/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/social/d_social_19-Dec-2024.mat');
addpath(genpath('/zi-flstorage/data/Danai/OFC-AI_cohort/scripts/analysis/helper/'));
addpath(genpath('/zi-flstorage/data/Danai/OFC-AI_cohort/scripts/analysis/familiar_1novel/'));

%% single-unit response plots
cd('/zi-flstorage/data/Angela/DATA/TD23/Plots/UnitInfo/recognition_headfix/20240707_png/');


for un = 1:numel(d.spikes)
    cur_events = d.events{1,d.map(un)};
    trialtimes = [cur_events.fv_on];
    spxtimes = d.spikes{1,un};
    f = plot_PSTH_familiarity_TD23(spxtimes,trialtimes,[cur_events.case_num],'post',4000,'binsize',50);
    f.Units = 'centimeters';
    f.Position =  [1 1 50 30];
%     axes('Position',f.Position.*[0 0 1 1], 'Box', 'off', 'Color', 'none', 'YColor', 'none', 'XColor','none');
%     text(.5,.95, d.clust_params(un).session+" Trode: "+string(d.clust_params(un).trode)+" Unit_Nr. "+ string(un), 'FontSize',15,'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')
    sgtitle([d.clust_params(un).session, '. Trode: ',num2str(d.clust_params(un).trode), ' Unit_Nr. ', num2str(un)],'Interpreter','none')  
%     set_fonts();
    exportgraphics(f,[num2str(un),'_PSTH.png'],'ContentType','vector','BackgroundColor','none');
    close all;

    g = plot_unitInfo(spxtimes,d.clust_params(un).wf);
    g.Units = 'centimeters';
    % g.Position =  [3 3 16 9];
    sgtitle([d.clust_params(un).session, '. Trode: ',num2str(d.clust_params(un).trode),' Unit_Nr. ', num2str(un)],'Interpreter','none')  
    set_fonts();
    exportgraphics(g,[num2str(un),'_info.png'],'ContentType','vector','BackgroundColor','none');
    close all;    
end
