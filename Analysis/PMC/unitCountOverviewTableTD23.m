%% Overview table for TD23
% - how many units recorded per animal and session
% - both as excel and plot?
% saveStr = "/zi-flstorage/data/Mirko/TD23/Plots/EPhys/Units/TD23_Unitcount_Overview("+string(d.filename)+")";
% saveStr = "/zi-flstorage/data/Angela/DATA/TD23/Plots/UnitCount("+string(d.filename)+")";
saveStr = "/zi-flstorage/data/Angela/DATA/TD23/Plots/UnitCount/UnitCount_byRegion";

[~,dayIdx] = unique([d.info.tag_ncount]);
dayPara = string({d.info(dayIdx(2:end)).tag});
animals = ["x0"+string(1:9),"x10"];
utypes = ["pMSN" "pDAN"];
region = ["NAc" "Tu" "LVTA" "RVTA"];
side = ["L" "R"];
plt =0;

overTable = table(NaN(41,1));
for ax = 1:numel(animals)
    for tx = 1:41
        for utx= 1:2
            for sd = 1:2
                if utx == 1
                    if sd == 1
                        reg = region(2);
                    else
                        reg = region(1);                      
                    end
                else
                    if sd == 1
                        reg = region(3);
                    else
                        reg = region(4);                      
                    end
                end
                unitCount = sum(UnitSelectionMod(d,side(sd)+"Animal("+animals(ax)+")"+revCase(utypes(utx))+"Sct("+string(tx)+")"));
                overTable.(animals(ax)+"_"+utypes(utx)+"_"+reg)(tx)= unitCount;
            end                
%             for rg = 1:4
%                 if rg == 2 || rg == 3
%                     sd = 1;                    
%                     unitCount = sum(UnitSelectionMod(d,side(sd)+"Animal("+animals(ax)+")"+revCase(utypes(utx))+"Sct("+string(tx)+")"));
%                 else
%                     sd = 2;
%                     unitCount = sum(UnitSelectionMod(d,side(sd)+"Animal("+animals(ax)+")"+revCase(utypes(utx))+"Sct("+string(tx)+")"));
%         %             overTable.(animals(ax)+"_"+utypes(utx))(tx)= unitCount;
%                     overTable.(animals(ax)+"_"+utypes(utx)+"_"+region(rg))(tx)= unitCount;
%                 end

        end
    end
end
overTable=removevars(overTable,'Var1');
overTable.Properties.RowNames = string(1:41)+"_"+dayPara;

%%
if plt
    fig = figure('Position',[1 1 30 20]);  
    tiledlayout(1,numel(utypes))
    fig.Children(1).TileSpacing ="none";
    for utx = 1:numel(utypes)
        nexttile
        hmp = heatmap(overTable{:,utx:2:end});
        hmp.XDisplayLabels=animals;
        hmp.YDisplayLabels = regexprep(dayPara(1:end),"_"," ")+" "+ string(1:41);
        title('#'+utypes(utx))
        hmp.GridVisible = 'off';
        hmp.ColorScaling ='log';
    end
colormap parula    
end
docDataSrc(fig,saveStr,'unitCountOverviewTableTD23.m',1,'dSrc1',d.filename)

%% save plot and table
writetable(overTable,saveStr+".xls")
exportgraphics(fig,saveStr+".png");
close(fig)


 %% subfunctions
% function s= revCase(s) 
% % reverse string case between capital and lowercase letters
% if isstring(s)
%     s = char(s);
%     ifstring = true;
% else
%     ifstring = false;
% end
% 
% ilo=regexp(s,'([a-z])');
% iup=regexp(s,'([A-Z])');
% s(iup)=lower(s(iup));
% s(ilo)=upper(s(ilo));
% 
% if ifstring
%     s = string(s);
% end
% 
% end