%% create psth and eucleadian directly from d-struct without a detour over population files
%% inputs:
% d                 = dstruct
% uSelect           = char used to get unitselection via UnitSelectionMod.m
%               OR  = struct with .uids as vector with unit indices and .str as the char used for the selection
% plotting          = boolean for [psth eucleadian heatmap ...]

%% outputs
% figure handles: hmp, psf, edf

%% ToDos:
% - psth: make prettier
% - heatmap:
% -- bar to show stimulus times
%% MA 2402: modified from plotFromD.m

function [hmp,psf,edf] = plotFromiFR(d,iFR,uSelect,plotting,pvis,TM,varargin)%yLim,TM)
% addpath '/home/mirko.articus/GitHub/LMESuitefromWR/functions'

hmp =[]; psf = []; edf = [];

if pvis
    set(groot, 'DefaultFigureVisible', 'on')
else
    set(groot, 'DefaultFigureVisible', 'off')
end

if any(contains(varargin(1:2:end),'manipulation'))
    Manip = varargin{find(contains(varargin(1:2:end),'manipulation'))+1};
else    
   Manip = {0:1};
end
    
    
    
if ischar(uSelect)|isstring(uSelect)
    selectStr = uSelect;
    uIDs = find(UnitSelectionMod(d,uSelect));
    clear uSelect
    uSelect.uids = uIDs;
    uSelect.str = selectStr;
elseif isstruct(uSelect)
    uIDs = uSelect.uids;
    selectStr = uSelect.str;
else
    uIDs = uSelect;
    selectStr = "";
end

if ~exist('TM','var'); TM = getTM(d); elseif isempty(TM); TM = getTM(d);end
%% heatmap
if plotting(1)
    for mx = 1:numel(Manip)
        hmp(mx) = heatmapFromiFR(d,iFR,uSelect,Manip{mx},TM);
    end
end


%% mean PSTH
if plotting(2)    
    psf = PSTHfromiFR(d,iFR,uIDs,TM,'manipulation',Manip);%figure('Position',[1 1 figs(2,:)]);
    
    %add title
    axes('Position',psf.Position.*[0 0 1 1],'Box','off','Color','none','YColor','none','XColor','none');
    text(.4,.99,{selectStr;[num2str(numel(uIDs)) ' Units']},'FontSize',12,'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')
    psf.Position = psf.Position+[0 0 0 .5];
    psf.Children = psf.Children([2:end 1]);
end


%% eucleadian distance
% compute baseline
if plotting(3)
    t0Vec = [stimWin(1,1):binsize:stimWin(1,2)-binsize];
    t0=find(t0Vec==0);
    
    collect=[];
    for s=1:size(spikeTrialMatrixSw,2)
        if ~isempty(spikeTrialMatrixSw{1,s})
            aus=mean(spikeTrialMatrixSw{1,s}(:,:,1:t0-1),3,'omitnan');
            collect=[collect; aus];
        end
    end
    Mean_baseline_all=mean(collect,1,'omitnan')';
    
    
    edf = figure('Position',[1 1 figs(2,:)]);
    for e = 1:size(spikeTrialMatrixSw,1)-jitter
        edax(e) = axes('Position',[e+ps(1)*(e -1) 1 ps]);
        [colorlabel,legstr] = get_coleg(epocStrs{e},states(2,e),jitter);
        if sepStim
            legstr = legstr(sepIx);
            colorlabel =colorlabel(sepIx);
        end
        %         timevec =1000*[stimWin(e,1):binsize:stimWin(e,2)-binsize;stimWin(e,1)+binsize:binsize:stimWin(e,2)]';
        if e == 1
            str={selectStr;[num2str(size(spikeTrialMatrixSw{1,1},2)) ' units - ' epocStrs{e}]};
        else
            str = epocStrs{e};
        end
        for s = 1:sum(~cellfun(@isempty,{spikeTrialMatrixSw{e,:}}))
            %                 currStimNum = sum(~cellfun(@isempty,{spikeTrialMatrixSw{e,:}}));
            %                 plot_DISTANCE(spikeTrialMatrixSw(e,1:currStimNum),Mean_baseline_all,timevec,colorlabel,legstr,str);
            [Edist,binsvect,~] = compEDist(spikeTrialMatrixSw(e,s),Mean_baseline_all,timevec);
            
            boundedline(binsvect,mean(Edist{1},'omitnan'), std(Edist{1},'omitnan')/sqrt(size(Edist{1},1))*1.96,'cmap',colorlabel{s},'alpha');%,'k');
            hold on
            p(s) = plot(binsvect,mean(Edist{1},'omitnan'),'LineWidth',1.5,'Color',colorlabel{s});
            
        end
        if e == 1
            title({selectStr;[num2str(size(freqTrialMatrixSw{1,1},2)) ' units - ' epocStrs{e}]},'Fontsize',fs)
        else
            title(epocStrs{e})
        end
        
        edf.leg = chngleg(p,legstr,colorlabel,figs,fs);
        legend('toggle')
        xlabel('time(sec)')
        if e==1; ylabel('eucleadian distance'); end
    end
    linkaxes
    stimBars = {{0 1.2},{0 1.2},{0}};
    for s = 1:numel(stimBars)-jitter
        axes(edax(s))
        for b = 1:numel(stimBars{s})
            if s==numel(stimBars)-jitter
                plot([stimBars{s}{b} stimBars{s}{b}],ylim,'r--','LineWidth',.25)
            else
                plot([stimBars{s}{b} stimBars{s}{b}],ylim,'k--','LineWidth',.25)
            end
            edax(s).Legend.String=edax(s).Legend.String(1:end-1);
        end
    end
end

set(0, 'DefaultFigureVisible', 'on')
end

%% subfunctions


% change legends
function tmp=chngleg(p,ax,legstr,colorlabel,figs,fs)
% l = legend(p,{legstr},'Interpreter','tex');
% get(l,'Position');
set(gcf,'CurrentAxes',ax)
tmppostxt = [ax.XLim(1)+diff(ax.XLim)*.75 ax.YLim(2)-diff(ax.YLim)*.1];
for lx = 1:size(legstr,2)
    tmp(lx) = text(tmppostxt(1),tmppostxt(2),legstr(:,lx),'Color',colorlabel{lx},'FontSize',fs,'Interpreter','tex');
    tmppostxt = tmppostxt -[0 diff(ax.YLim)*.1];
end
%% annotations do not get copied to parent figure using combine figure, text does!
% tmppos = [(ans(1:2)+ans(4))./figs(2,:) 1 0];
% for lx = 1:size(legstr,1)
%     tmp(lx) = annotation('textbox',tmppos,'String',legstr(lx,:),'Color',colorlabel{lx},'LineStyle','none','FontSize',fs);
%     tmppos = tmppos - [0 .2/ans(2) 0 0];
% end
end


% create trialmatrix => outsourced to function file
% function [TM,Jitt] = getTM(d)
% TM = NaN(numel(d.spikes),3,150);
% Jitt = NaN(numel(d.spikes),1,150);
% for sx = unique(d.map)
%     events = d.events{sx};
%     try
%         TMs = [[events.curr_odorcue_odor_num]; [events.curr_rewardcue_odor_num];[events.drop_or_not];[events.inhibit_or_not]];
%     catch
%         try
%             TMs = [[events.curr_odorcue_odor_num]; [events.curr_rewardcue_odor_num];[events.drop_or_not];[events.excite_or_not]];
%         catch
%             TMs = [[events.curr_odorcue_odor_num]; [events.curr_rewardcue_odor_num];[events.drop_or_not];zeros(size([events.drop_or_not]))];
%         end
%     end
%     TMs(1,TMs(1,:)==10) = 6;
%     try 
%         JittS = [events.jitter_OC_RC];
%     catch
%         JittS = NaN(1,numel(events));
%     end
%     for ux = find(d.map==sx)
%         TM(ux,:,1:size(TMs,2)) = TMs;
%         Jitt(ux,1,1:numel(JittS)) = JittS;
%     end
%     
% end
% end