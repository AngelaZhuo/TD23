%% unit count per tetrode

load '/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/d_15-Mar-2024.mat'
clearvars -except d
tetrodes = 1:max([d.clust_params.tetrode]);
animals = ["x0"+string(1:9) "x10"];

for ax =1:numel(animals)
   unitPerTetrode = NaN(1,numel(tetrodes));   
   for tx =1:numel(tetrodes)
       if tx < 33
           unitPerTetrode(tx) = sum(UnitSelectionMod(d,"Animal("+animals(ax)+")PmsnTx("+string(tx)+")X(pmc)"));
       else
           unitPerTetrode(tx) = sum(UnitSelectionMod(d,"Animal("+animals(ax)+")PdanTx("+string(tx)+")X(pmc)"));
       end
   end
   figure
   bar(unitPerTetrode)
   title([animals(ax),' Pmsn+Pdan ']);
   xlabel('Tetrode')
   ylabel('Number')
   exportgraphics(gcf,fullfile('/zi-flstorage/data/Angela/DATA/TD23/Plots/UnitCount',[char(animals(ax)) '_perTetrode_PMC.png']))
   close all
end

%% Plot the unit info
% For the decision of setting the region of the tetrode in the channel map as 99 (out of the region)
% Make some plots of the units in tetrodes that have low unit count
clearvars -except d

% set(groot,'defaultFigureUnits','centimeters')
Ulog = UnitSelectionMod(d,"Animal(x10)PdanTx(40)");
Uix = find(Ulog);
for un=1:numel(Uix)
    f = plot_unitInfo(d.spikes{Uix(un)},d.clust_params(Uix(un)).wf,[0 0 50 20]);
    sgtitle([d.info(d.map(Uix(un))).animal, '_tetrode ', num2str(d.clust_params(Uix(un)).tetrode)],'Interpreter','none')
    exportgraphics(gcf,fullfile('/zi-flstorage/data/Angela/DATA/TD23/Plots/UnitInfo',['x10_tx',num2str(d.clust_params(Uix(un)).tetrode),'_un',num2str(Uix(un)),'.png']))
    close
end


%% Make a table of the unit count

% load ('/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/d_09-Apr-2024.mat')

clearvars -except d
animals = ["x0"+string(1:9) "x10"];
tag_ncount = unique([d.info.tag_ncount]);
tag_ncount = tag_ncount(2:end);

for ses = 1:numel(tag_ncount)
    ses_tag{ses} = d.info(ismember([d.info.tag_ncount],tag_ncount(ses))).tag;
    for ax = 1:numel(animals)
    pMSN(ses,2*ax-1) = sum(UnitSelectionMod(d,"PmsnSct(" +string(ses)+ ")Animal("+animals(ax)+")"));
    pDAN(ses,2*ax) = sum(UnitSelectionMod(d,"PdanSct(" +string(ses)+ ")Animal("+animals(ax)+")"));
    Variables{2*ax-1} = "pMSN_"+animals(ax);
    Variables{2*ax} = "pDAN_"+animals(ax);
    end
end

zero_column = zeros(41,1);
pMSN = cat(2,pMSN,zero_column);
all = pMSN + pDAN;
T = array2table(all,"VariableNames",string(Variables));

T = [table(ses_tag','VariableNames',{'ses_tag'}) T]; %concatenate the table
writetable(T,'/zi-flstorage/data/Angela/DATA/TD23/Plots/UnitCount/Unitcount_Overview(d_09-Apr-2024.mat).xls')
