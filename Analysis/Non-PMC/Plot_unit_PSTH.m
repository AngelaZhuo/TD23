%% Plot individual unit raster and PSTH and save based on their odor-tuning
%TD23 fam2novel experiment 

folder = "/zi-flstorage/data/Angela/DATA/TD23/Plots/UnitInfo/recognition_headfix";
set(groot,'DefaultFigureVisible','off')

for un = 1:length(d.clust_params)
    cur_events = d.events{1,d.map(un)};
    trialtimes = [cur_events.fv_on];
    spxtimes = d.spikes{1,un};
    curr_unit  = d.clust_params(un);
    
    if curr_unit.region_coding == 1
        if curr_unit.mean_fr > 5 || curr_unit.mean_fr < 0.25
            continue
        else
            f = plot_PSTH_familiarity_TD23(spxtimes,trialtimes,[cur_events.case_num],'post',4000,'binsize',50);
            f.Units = 'centimeters';
            f.Position =  [1 1 50 30];
            sgtitle([curr_unit.session(5:10),' region: ',curr_unit.region, ' Trode: ',num2str(curr_unit.trode), ' Unit_Nr. ', num2str(un)],'Interpreter','none')
            if any(sum([curr_unit.ex_fam,curr_unit.ex_nov1,curr_unit.ex_nov2]))
                if any(sum([curr_unit.inh_fam,curr_unit.inh_nov1,curr_unit.inh_nov2]))
                    fa = annotation('textbox',[.4 .4 .1 .1],'string',['exc for ',num2str(sum([curr_unit.ex_fam,curr_unit.ex_nov1,curr_unit.ex_nov2])),...
                        ' odor(s);  inh for ', num2str(sum([curr_unit.inh_fam,curr_unit.inh_nov1,curr_unit.inh_nov2])),' odor(s)'],'Interpreter','none','FontSize',14);
                    saveas(gcf,folder + "/mixed/NAc/unit"+string(un)+".png");
                else
                    fa = annotation('textbox',[.4 .4 .1 .1],'string',['exc for ',num2str(sum([curr_unit.ex_fam,curr_unit.ex_nov1,curr_unit.ex_nov2])),...
                        ' odor(s)'],'Interpreter','none','FontSize',14);
                    saveas(gcf,folder + "/odor-excited/NAc/unit"+string(un)+".png");

                end
            elseif any(sum([curr_unit.inh_fam,curr_unit.inh_nov1,curr_unit.inh_nov2]))
                    fa = annotation('textbox',[.4 .4 .1 .1],'string',['inh for ',num2str(sum([curr_unit.inh_fam,curr_unit.inh_nov1,curr_unit.inh_nov2])),...
                        ' odor(s)'],'Interpreter','none','FontSize',14);
                saveas(gcf,folder + "/odor-inhibited/NAc/unit"+string(un)+".png");

            else
                saveas(gcf,folder + "/no-resp/NAc/unit"+string(un)+".png");
            end
        end
    elseif curr_unit.region_coding == 2
        if curr_unit.mean_fr > 5 || curr_unit.mean_fr < 0.25
            continue
        else
            f = plot_PSTH_familiarity_TD23(spxtimes,trialtimes,[cur_events.case_num],'post',4000,'binsize',50);
            f.Units = 'centimeters';
            f.Position =  [1 1 50 30];
            sgtitle([curr_unit.session(5:10), ' region: ',curr_unit.region,' Trode: ',num2str(curr_unit.trode), ' Unit_Nr. ', num2str(un)],'Interpreter','none')
            if any(sum([curr_unit.ex_fam,curr_unit.ex_nov1,curr_unit.ex_nov2]))
                if any(sum([curr_unit.inh_fam,curr_unit.inh_nov1,curr_unit.inh_nov2]))
                    fa = annotation('textbox',[.4 .4 .1 .1],'string',['exc for ',num2str(sum([curr_unit.ex_fam,curr_unit.ex_nov1,curr_unit.ex_nov2])),...
                        ' odor(s);  inh for ', num2str(sum([curr_unit.inh_fam,curr_unit.inh_nov1,curr_unit.inh_nov2])),' odor(s)'],'Interpreter','none','FontSize',14);
                    saveas(gcf,folder+"/mixed/OT/unit"+string(un)+".png");
                else
                    fa = annotation('textbox',[.4 .4 .1 .1],'string',['exc for ',num2str(sum([curr_unit.ex_fam,curr_unit.ex_nov1,curr_unit.ex_nov2])),...
                        ' odor(s)'],'Interpreter','none','FontSize',14);
                    saveas(gcf, folder+ "/odor-excited/OT/unit"+string(un)+".png");
                end
            elseif any(sum([curr_unit.inh_fam,curr_unit.inh_nov1,curr_unit.inh_nov2]))
                    fa = annotation('textbox',[.4 .4 .1 .1],'string',['inh for ',num2str(sum([curr_unit.inh_fam,curr_unit.inh_nov1,curr_unit.inh_nov2])),...
                        ' odor(s)'],'Interpreter','none','FontSize',14);
                saveas(gcf,folder+"/odor-inhibited/OT/unit"+string(un)+".png");
            else
                saveas(gcf,folder+"/no-resp/OT/unit"+string(un)+".png");
            end
        end
    elseif curr_unit.region_coding == 3
        if curr_unit.mean_fr <1 || curr_unit.mean_fr>12
            continue
        else
            f = plot_PSTH_familiarity_TD23(spxtimes,trialtimes,[cur_events.case_num],'post',4000,'binsize',50);
            f.Units = 'centimeters';
            f.Position =  [1 1 50 30];
            sgtitle([curr_unit.session(5:10), ' region: ',curr_unit.region,' Trode: ',num2str(curr_unit.trode), ' Unit_Nr. ', num2str(un)],'Interpreter','none')
            if any(sum([curr_unit.ex_fam,curr_unit.ex_nov1,curr_unit.ex_nov2]))
                if any(sum([curr_unit.inh_fam,curr_unit.inh_nov1,curr_unit.inh_nov2]))
                    fa = annotation('textbox',[.4 .4 .1 .1],'string',['exc for ',num2str(sum([curr_unit.ex_fam,curr_unit.ex_nov1,curr_unit.ex_nov2])),...
                        ' odor(s);  inh for ', num2str(sum([curr_unit.inh_fam,curr_unit.inh_nov1,curr_unit.inh_nov2])),' odor(s)'],'Interpreter','none','FontSize',14);
                    saveas(gcf,folder+"/mixed/VTA/unit"+string(un)+".png");
                else
                    fa = annotation('textbox',[.4 .4 .1 .1],'string',['exc for ',num2str(sum([curr_unit.ex_fam,curr_unit.ex_nov1,curr_unit.ex_nov2])),...
                        ' odor(s)'],'Interpreter','none','FontSize',14);
                    saveas(gcf, folder+ "/odor-excited/VTA/unit"+string(un)+".png");
                end
            elseif any(sum([curr_unit.inh_fam,curr_unit.inh_nov1,curr_unit.inh_nov2]))
                    fa = annotation('textbox',[.4 .4 .1 .1],'string',['inh for ',num2str(sum([curr_unit.inh_fam,curr_unit.inh_nov1,curr_unit.inh_nov2])),...
                        ' odor(s)'],'Interpreter','none','FontSize',14);
                saveas(gcf,folder+"/odor-inhibited/VTA/unit"+string(un)+".png");
            else
                saveas(gcf,folder+"/no-resp/VTA/unit"+string(un)+".png");
            end
        end
    end

    close all

end