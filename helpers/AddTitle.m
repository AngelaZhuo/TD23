%add title
ulog = UnitSelectionMod(d,"TuPmsnX(cs2delay_silence)Animal(x04,x07,x08,x09,x10)");

axes('Position',psf.Position.*[0 0 1 1],'Box','off','Color','none','YColor','none','XColor','none');

% text(.5,.99,"NAC - CS1delay_silence "+string(sum(ulog))+" Units",'FontSize',10,'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')
text(.5,.99,"Tu - CS2delay_silence "+string(numel(uids_new))+" Units",'FontSize',10,'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')

psf.Position = psf.Position+[0 0 0 .5];

psf.Children = psf.Children([2:end 1]);

% exportgraphics(psf,'/zi-flstorage/data/Angela/DATA/TD23/Plots/TAC_Meeting/learned_NAc_CS1delaysilence.png');
exportgraphics(psf,'/zi-flstorage/data/Angela/DATA/TD23/Plots/TAC_Meeting/non-inhibited_units_only/learned_Tu_CS2delaysilence.png');