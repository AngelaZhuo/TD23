%add title
% ulog = UnitSelectionMod(d,"PdanX(sham)Animal(x04,x07,x08,x09,x10)");

axes('Position',psf.Position.*[0 0 1 1],'Box','off','Color','none','YColor','none','XColor','none');

% text(.5,.99,"VTA - sham "+string(sum(ulog))+" Units",'FontSize',10,'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')
text(.5,.99,"VTA - sham "+string(numel(uids_new))+" Units",'FontSize',10,'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')

psf.Position = psf.Position+[0 0 0 .5];

psf.Children = psf.Children([2:end 1]);

% exportgraphics(psf,'/zi-flstorage/data/Angela/DATA/TD23/Plots/TAC_Meeting/learned_VTA_sham.png');
exportgraphics(psf,'/zi-flstorage/data/Angela/DATA/TD23/Plots/TAC_Meeting/excited_units_only/learned_VTA_sham.png');