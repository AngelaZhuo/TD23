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
