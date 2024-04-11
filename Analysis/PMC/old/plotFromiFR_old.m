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

function [hmp,psf,edf] = plotFromiFR_old(d,iFR,uSelect,plotting,pvis,yLim,TM)
% addpath '/home/mirko.articus/GitHub/LMESuitefromWR/functions'
set(groot,'Units','centimeters')
%settings
%plot stuff
figs = [10 20;15 5]; % heatmap; psth & eucleadian
fs = 6; %fontsize
ps = [figs(2,1)*.225 figs(2,2)*.675;...
    figs(2,1)*.225 figs(2,2)*.675;...
    figs(2,1)*.45 figs(2,2)*.675];
set(groot,'DefaultFigureWindowStyle','normal')
set(groot,'defaultAxesTickLabelInterpreter','tex');
hmp =[]; psf = []; edf = [];
cmp = "redblue";
if pvis
    set(groot, 'DefaultFigureVisible', 'on')
else
    set(groot, 'DefaultFigureVisible', 'off')
end

Manip = 0; % for now only plot sham trials 
binsize = 0.1; %sec diff(stimWin)/binsize has to be integer
binNumSw = 4;
patchColor = [.7 .7 .7;.9 0 0];
% stimulus windows
% Events = [20.5000   33.0000   45.0000   54.5000   67.0000   79.0000  164.0000]; Events = floor(Events);
Events = round([21, 33.4, 39, 45.4, 57.8, 79, 164]);

stimWin(1,:) = [Events(1)-10 Events(1)+24];
timevec{1} = -1:binsize:diff(stimWin(1,:)*binsize)-1;
stimWin(2,:) = [Events(4)-10 Events(4)+24];
timevec{2} = -1:binsize:diff(stimWin(2,:)*binsize)-1;
stimWin(3,:) = [Events(6)-10 Events(6)+59];
timevec{3} = -1:binsize:diff(stimWin(3,:)*binsize)-1;
states = [1 1 1;1 2 2];

epocStrs ={'CS1','CS2','US'};
if ischar(uSelect)|isstring(uSelect)
    selectStr = uSelect;
    uIDs = find(UnitSelectionMod(d,uSelect));
elseif isstruct(uSelect)
    uIDs = uSelect.uids;
    selectStr = uSelect.str;
end
iFRslct = iFR(uIDs,:,:);

% create trialmatrix TM (#units x 3trialcode x #trials)
if ~exist('TM','var')
    TM = getTM(d);
end
TMslct = TM(uIDs,:,:);
[animals,~,anUID] = unique({d.clust_params(uIDs).animal});

iFR_ = [];
TM_ = [];
Mauser = [];
Sesser = [];
uIDvec = [];
for ux = 1:numel(uIDs)
    iFR_ = cat(3, iFR_, iFRslct(ux, :, 1:end));
    TM_ = cat(3, TM_, TMslct(ux, :, 1:end));
    uIDvec = cat(1, uIDvec, ux*ones(numel(1:150),1));
    Mauser = cat(1, Mauser, anUID(ux)*ones(150,1));
    Sesser = cat(1, Sesser,d.map(uIDs(ux))*ones(150,1));
end

% z-score iFR
iFR_z = iFR_;
for ux = 1:numel(uIDs)
    %     ##check
    iFR_z(:,:,uIDvec==ux)   = (iFR_(:,:,uIDvec==ux)-mean(iFR_(:,:,uIDvec==ux),'all','omitnan'))/std(iFR_(:,:,uIDvec==ux),0,'all','omitnan');
end
%% heatmap

if plotting(1)
    
    hmatrix = [];
    stimBins = [];
    timevecHmp = [];
    sc = 1;
    legstr = char();
    
    for e = 1:3
        [~,currlegstr,code] = get_colegcode(epocStrs{e},states(1,e));
        legstr = char(legstr,currlegstr);
        for s = 1:size(code,1)
            trx = squeeze(PSTHindex(TM_,code(s,:),Manip));
            iFR__ = iFR_z(:,stimWin(e,(1)):stimWin(e,(2)),trx);
            unMeans = [];
            for ux = 1:numel(uIDs)
                unMean = mean(iFR_z(:,stimWin(e,(1)):stimWin(e,(2)),ux==uIDvec&trx),3,'omitnan');
                %                 unMean = nanmean(iFR__(:,:,ux==uIDvec(trx)),3);
                %                 unMean = movsum(nanmean(iFR__(:,:,ux==uIDvec(trx)),3),5);
                unMeans = cat(1,unMeans,unMean);
            end
            currStimStart = size(hmatrix,2)+find(timevec{e}==0);
            if e==3
                timevecHmp = cat(2,timevecHmp,[currStimStart currStimStart+1]);
            else
                timevecHmp = cat(2,timevecHmp,[currStimStart currStimStart+12]);
            end
            hmatrix = cat(2,hmatrix,unMeans);
            stimBins = cat(1,stimBins,size(hmatrix,2));
            
        end
    end
    meanidx = [];
    for tvx = 1:2:numel(timevecHmp)
        meanidx = [meanidx timevecHmp(tvx):timevecHmp(tvx+1)];
    end
    [~,idx] = sort(mean(hmatrix(:,meanidx),2,'omitnan'));
    hmatrix=hmatrix(idx,:);
    %%
    hmp = figure('Position',[1 1 figs(1,:)]);
        
    % heatmap
    is = imagesc(hmatrix);
    colormap(cmp)
    hold on
    is_axis = gca;
    is_axis.FontSize =fs;
%     is
    stimSep = stimBins+0.5;
    for sb = 1:numel(stimBins)-1
        plot([stimSep(sb) stimSep(sb)], ylim,'k:','LineWidth',.5)
    end
    title(selectStr)
    ylabel('units')
    yticks([0:10:floor(max(ylim))])
    is_axis.YLabel.Position(1) = is_axis.Position(1)-2.5;
    
    xlabel('stimuli')
    is_axis.XLabel.Position(2) = is_axis.XLabel.Position(2)*1.025;
%     xticks(timevecHmp)
    xticks([])
%     legstr = cellstr(legstr(2:end,:));
%     legstrSpace = cell(1,numel(legstr)*2);
%     legstrSpace(1:2:end)=legstr(:);
    
%     xticklabels(legstrSpace)
    cb=colorbar;
    cb.Label.String='z-score';
    cb.Ticks = cb.Limits;
    cb.TickLabels = string(round(cb.Limits,2));
    cb.Label.Position(1)=cb.Position(1)+cb.Position(3)+.2;
    
    %     xtickangle(-30)
    box('off')
    is_axis.XAxis.TickDirection ='out';
    is_axis.XAxis.FontSize = fs;
    
    % stim patches
    phmax=axes('Position',[is_axis.Position(1) is_axis.Position(2)-.8 is_axis.Position(3) .8],'Color','none');
    phmax.YAxis.Visible = 'off';
    phmax.XAxis.Visible = 'off';   
    ylim([0 1])
    xlim([0 size(hmatrix,2)])
    legstr = cellstr(legstr(2:end,:));
    legstrSpace = cell(1,numel(legstr)*2);
    legstrSpace(1:2:end)=legstr(:);
    
    pcl=1;
    for s=1:2:numel(timevecHmp)
        if s/4<sum(states(1:2))
            patch([timevecHmp(s) timevecHmp(s+1) timevecHmp(s+1) timevecHmp(s)],[.5 .5 .95 .95],patchColor(1,:),'EdgeColor','none')
            text(timevecHmp(s)+diff(timevecHmp(s:(s+1)))/5,0.1,legstrSpace{s})
        else
            patch([timevecHmp(s) timevecHmp(s+1) timevecHmp(s+1) timevecHmp(s)],[.5 .5 .95 .95],patchColor(2,:),'EdgeColor','none')
            text(timevecHmp(s)+diff(timevecHmp(s:(s+1)))/2,0.1,legstrSpace{s})
        end
        
        %     annotation('textbox',[timevecHmp(s)/diff(is_axis.XLim) 0 (timevecHmp(s+1)-timevecHmp(s))/diff(is_axis.XLim) 1],'String','A','FitBoxToText','on')%/ timevecHmp(s+1) timevecHmp(s)]
    end
end


%% mean PSTH
% region

if plotting(2)
    % transform Spike count to frequency
    psf = figure('Position',[1 1 figs(2,:)]);
    
    
    for e = 1:3
        psax(e) = axes('Position',[1+(e-1)*.225+ps(1,1)*(e -1) 1 ps(e,:)]);
        [colorlabel{e},legstr{e},code] = get_colegcode(epocStrs{e},states(2,e),0);
        clear p l
        for s = 1:size(code,1)
            %             calculate average and standard error on the unitlevel then propagate
            %             -> results in high errors and ugly plots -> pool units per mouse
                        unMean = NaN(numel(uIDs), numel(timevec{e}));
                        unSE = NaN(numel(uIDs), numel(timevec{e}));
                        for ux = 1:numel(uIDs)
                            iFR__ = iFR_z(:,stimWin(e,(1)):stimWin(e,(2)),uIDvec==ux);
                            trx = PSTHindex(TM_(:,:,uIDvec==ux),code(s,:),Manip);
                            unMean(ux,:) = mean(iFR__(:,:,trx),3,'omitnan');
                            unSE(ux,:) = std(iFR__(:,:,trx),0,3,'omitnan')/sqrt(sum(trx));
%                            # trx = squeeze(PSTHindex(TM_,code(s,:),Manip));
%                            # unMean(ux,:) = mean(iFR_z(:,stimWin(e,(1)):stimWin(e,(2)),uIDvec==ux&trx),3,'omitnan');
%                            # unSE(ux,:) = std(iFR_z(:,stimWin(e,(1)):stimWin(e,(2)),uIDvec==ux&trx),0,3,'omitnan')/sqrt(sum(trx));
                        end

            
            anMean = NaN(numel(animals), numel(timevec{e}));
            anSE = NaN(numel(animals), numel(timevec{e}));
            trx = squeeze(PSTHindex(TM_,code(s,:),Manip));
            
            for ax = 1:numel(animals)
                % error propagation animal->population
%                 anMean(ax,:) = mean(iFR_(:,stimWin(e,(1)):stimWin(e,(2)),Mauser==ax&trx),3,'omitnan');
%                 anSE(ax,:) = std(iFR_(:,stimWin(e,(1)):stimWin(e,(2)),Mauser==ax&trx),0,3,'omitnan')/sqrt(sum(Mauser==ax&trx));
                % zscored
%                 anMean(ax,:) = mean(iFR_z(:,stimWin(e,(1)):stimWin(e,(2)),Mauser==ax&trx),3,'omitnan');
%                 anSE(ax,:) = std(iFR_z(:,stimWin(e,(1)):stimWin(e,(2)),Mauser==ax&trx),0,3,'omitnan')/sqrt(sum(Mauser==ax&trx));
                
                                % error propagation unit->animal->population
                                anMean(ax,:) = mean(unMean(anUID==ax,:),1,'omitnan');
                                anSE(ax,:) = sqrt(sum((unSE(anUID==ax,:)/sum(anUID==ax)).^2,1)); % corrected error propagation MArticus 240304 
                                %               ##  anSE(ax,:) = sqrt(squeeze(mean(unSE(anUID==ax,:).^2,1,'omitnan')));
%                                 ## anSE(ax,:) = sqrt(sum((unSE(anUID==ax,:)/size(unSE,1)).^2,1)); % corrected error propagation MArticus 240304 

            end
            % error propagation
            M=mean(anMean,1,'omitnan');
%            ## SE= sqrt(mean(anSE.^2,1,'omitnan'));
            SE= sqrt(sum((anSE/size(anSE,1)).^2,1)); % corrected error propagation MArticus 240304 
            
            % No error propagation, taking the mean across all trials of
            % all units pooled together
%             M =  mean(iFR_z(:,stimWin(e,(1)):stimWin(e,(2)),trx),3,'omitnan');
%             SE = std(iFR_z(:,stimWin(e,(1)):stimWin(e,(2)),trx),0,3,'omitnan')/sqrt(sum(trx));
            
            
            boundedline(timevec{e},M,SE*1.96,'cmap',colorlabel{e}{s},'alpha');
            if s==1
                hold on
                if e == 1
                    title({selectStr;[num2str(numel(uIDs)) ' units - ' epocStrs{e}]},'Fontsize',fs)
                else
                    title(epocStrs{e})
                end
            end
            p{e}(s) = plot(timevec{e},M,'LineWidth',1.5,'Color',colorlabel{e}{s});
        end
        
%         legend('toggle')
%         legend('boxoff')
        xlabel('time(sec)')
        if e == 1
            ylabel('iFR z-scored'); 
        else
            yticklabels([])
            psax(e).YTickMode ='auto';
        end
        xlim([timevec{e}(1) timevec{e}(end)])
    end
    if exist('yLim','var')
        if isempty(yLim)
            linkaxes(psax,'y')
        else
            set(psax,'YLim',yLim)
        end
    else
        linkaxes(psax,'y')
    end
    
    for e =1:e
        chngleg(p{e},psax(e),legstr{e},colorlabel{e},figs,fs);
    end
    
    stimBars = {{0 1.2},{0 1.2},{0}};
    for s = 1:numel(stimBars)
        %                 axes(psax(s));
        set(psf,'CurrentAxes',psax(s))
        yLim = ylim;
        if s==numel(stimBars)
            patch([stimBars{s}{1} stimBars{s}{1}+.1 stimBars{s}{1}+.1 stimBars{s}{1}],[yLim(2)-diff(yLim)*.05 yLim(2)-diff(yLim)*.05 yLim(2) yLim(2)],patchColor(2,:),'EdgeColor','none','FaceAlpha',1)
            %                 plot([stimBars{s}{b} stimBars{s}{b}],ylim,'r--','LineWidth',.25)
        else
            patch([stimBars{s}{[1 2]} stimBars{s}{[2 1]}],[yLim(2)-diff(yLim)*.05 yLim(2)-diff(yLim)*.05 yLim(2) yLim(2)],patchColor(1,:),'EdgeColor','none','FaceAlpha',1)
            %                 plot([stimBars{s}{b} stimBars{s}{b}],ylim,'k--','LineWidth',.25)
        end
%         psax(s).Legend.String=psax(s).Legend.String(1:end-1);
        %         for b = 1:numel(stimBars{s})
        %             if s==numel(stimBars)
        %                 plot([stimBars{s}{b} stimBars{s}{b}],ylim,'r--','LineWidth',.25)
        %             else
        %                 plot([stimBars{s}{b} stimBars{s}{b}],ylim,'k--','LineWidth',.25)
        %             end
        %             psax(s).Legend.String=psax(s).Legend.String(1:end-1);
        %         end
    end
end

%         %% single unit PSTH
%         %     -> implement if needed
%
%         if 1
%             psup =[];
%         else
%             %             set(0, 'DefaultFigureVisible', 'off')
%             freqTrialMatrixSw=cellfun(@(x) x/(binsize*binNumSw),spikeTrialMatrixSw,'UniformOutput',false);
%             for u = 1:numel(uIDs)
%                 psup(u) = figure('Position',[1 1 figs(2,:)]);
%                 for e = 1:size(freqTrialMatrixSw,1)-jitter
%                     psax(e) = axes('Position',[e+ps(1)*(e -1) 1 ps]);
%                     [colorlabel,legstr] = get_coleg(epocStrs{e},states(e));
%                     if sepStim
%                         legstr = legstr(sepIx);
%                         colorlabel =colorlabel(sepIx);
%                     end
%                     clear p
%                     for s = 1:sum(~cellfun(@isempty,{freqTrialMatrixSw{e,:}}))
%                         M=mean(squeeze(freqTrialMatrixSw{e,s}(:,u,:)),'omitnan');
%                         SE=std(squeeze(freqTrialMatrixSw{e,s}(:,u,:)),'omitnan')/sqrt(size(freqTrialMatrixSw{e,s},1));
%                         timevec =[stimWin(e,1):binsize:stimWin(e,2)-binsize];
%                         boundedline(timevec,M,SE*1.96,'cmap',colorlabel{s},'alpha');
%                         if s==1
%                             hold on
%                             %                     if e == 1
%                             %                         title({selectStr;[' unit ' num2str(u) ' ID ' num2str(uIDs(u))  ' - ' epocStrs{e}]},'Fontsize',fs)
%                             %                     else
%                             %                         title(epocStrs{e})
%                             %                     end
%                         end
%                         p(s) = plot(timevec,M,'LineWidth',1.5,'DisplayName',legstr{s},'Color',colorlabel{s});
%                     end
%                     %             legend(p,legstr)
%                     %             legend('boxoff')
%                     %             xlabel('time(sec)')
%                     %             ylabel('Hz')
%                 end
%                 linkaxes
%                 stimBars = {{0 1.2},{0 1.2},{0}};
%                 for s = 1:numel(stimBars)-jitter
%                     axes(psax(s))
%                     for b = 1:numel(stimBars{s})
%                         plot([stimBars{s}{b} stimBars{s}{b}],ylim,'k--')
%                         %                 psax(s).Legend.String=psax(s).Legend.String(1:end-1);
%                     end
%                 end
%             end
%             set(groot, 'DefaultFigureVisible', 'off')
%         end
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
    tmp(lx) = text(tmppostxt(1),tmppostxt(2),legstr(lx),'Color',colorlabel{lx},'FontSize',fs,'Interpreter','tex');
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