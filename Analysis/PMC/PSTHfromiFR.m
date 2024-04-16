function psf = PSTHfromiFR(d,iFR,uids,TM,varargin)
%input: load d-struct and iFR, uids is the string to put into UnitSelectionMod.m
%input: TM and varargin are optional

figs = [15 5]; % heatmap; psth & eucleadian
fs = 6; %fontsize
ps = [figs(1)*.225 figs(2)*.675;...
    figs(1)*.225 figs(2)*.675;...
    figs(1)*.45 figs(2)*.675];

binsize = 0.1; %sec diff(stimWin)/binsize has to be integer
patchColor = [.7 .7 .7;.9 0 0];

if ischar(uids)|isstring(uids)
    uids = find(UnitSelectionMod(d,uids));
end

if ~exist('TM','var'); TM = getTM(d); elseif isempty(TM); TM = getTM(d);end

    Events = round([21, 33.4, 39, 45.4, 57.8, 79, 164]);  % after pump realignment
%     Events = [21, 33, 39, 45, 57, 79, 164]; 
%     Events = [21 33 39 45 57 69 164]; % new one block


if any(contains(varargin(1:2:end),'manipulation'))
   Manip = varargin{find(contains(varargin(1:2:end),'manipulation'))*2};
else    
   Manip = {0:1};
end

if any(contains(varargin(1:2:end),'title'))
    Title = varargin{find(contains(varargin(1:2:end),'title'))*2};
else
    Title =[];
end

if numel(unique({d.info(d.map(uids)).tag}))==1
   para = cell2mat(unique({d.info(d.map(uids)).tag}));
else
    para =[];
end


stimWin(1,:) = [Events(1)-10 Events(1)+24];
timevec{1} = -1:binsize:diff(stimWin(1,:)*binsize)-1;
stimWin(2,:) = [Events(4)-10 Events(4)+24];
timevec{2} = -1:binsize:diff(stimWin(2,:)*binsize)-1;
stimWin(3,:) = [Events(6)-10 Events(6)+59];
timevec{3} = -1:binsize:diff(stimWin(3,:)*binsize)-1;
if numel(Manip)==1&&~all(Manip{1}==1)
   states = [1 2 2]; 
else
    states = [1 1 1];
end

epocStrs ={'CS1','CS2','US'};

psf = figure('Position',[1 1 figs]);
iFRslct = iFR(uids,:,:);
TMslct = TM(uids,:,:);
[animalSlct,~,anUID] = unique({d.clust_params(uids).animal});

iFR_ = [];
TM_ = [];
Mauser = [];
Sesser = [];
uIDvec = [];
for ux = 1:numel(uids)
    iFR_ = cat(3, iFR_, iFRslct(ux, :, 1:end));
    TM_ = cat(3, TM_, TMslct(ux, :, 1:end));
    uIDvec = cat(1, uIDvec, ux*ones(numel(1:150),1));
    Mauser = cat(1, Mauser, anUID(ux)*ones(150,1));
    Sesser = cat(1, Sesser,d.map(uids(ux))*ones(150,1));
end

% z-score iFR
iFR_z = iFR_;
for ux = 1:numel(uids)   
    iFR_z(:,:,uIDvec==ux)   = (iFR_(:,:,uIDvec==ux)-mean(iFR_(:,:,uIDvec==ux),'all','omitnan'))/std(iFR_(:,:,uIDvec==ux),0,'all','omitnan');
end





for e = 1:3
    psax(e) = axes('Position',[1+(e-1)*.225+ps(1,1)*(e -1) 1 ps(e,:)]);
    
    for mx = 1:numel(Manip) % first plot sham, then manip trials
        [colorlabel{e,mx},legstr{e,mx},code] = get_colegcode(epocStrs{e},states(e),'manipulation',Manip{mx},'paradigm',para);
        clear p l
        for s = 1:size(code,1)
            %             calculate average and standard error on the unitlevel then propagate
            %             -> results in high errors and ugly plots -> pool units per mouse
            %                 unMean = NaN(numel(uids), numel(timevec{e}));
            %                 unSE = NaN(numel(uids), numel(timevec{e}));
            %                 for ux = 1:numel(uids)
            %                     iFR__ = iFR_z(:,stimWin(e,(1)):stimWin(e,(2)),uIDvec==ux);
            %                     trx = PSTHindex(TM_(:,:,uIDvec==ux),code(s,:),mx);
            %                     unMean(ux,:) = mean(iFR__(:,:,trx),3,'omitnan');
            %                     unSE(ux,:) = std(iFR__(:,:,trx),0,3,'omitnan')/sqrt(sum(trx));
            %                 end
            
            
            anMean = NaN(numel(animalSlct), numel(timevec{e}));
            anSE = NaN(numel(animalSlct), numel(timevec{e}));
            trx = squeeze(PSTHindex(TM_,code(s,:),Manip{mx}));
            
            for axx = 1:numel(animalSlct)
                % error propagation animal->population
                %                 anMean(ax,:) = mean(iFR_(:,stimWin(e,(1)):stimWin(e,(2)),Mauser==ax&trx),3,'omitnan');
                %                 anSE(ax,:) = std(iFR_(:,stimWin(e,(1)):stimWin(e,(2)),Mauser==ax&trx),0,3,'omitnan')/sqrt(sum(Mauser==ax&trx));
                % zscored
                anMean(axx,:) = mean(iFR_z(:,stimWin(e,(1)):stimWin(e,(2)),Mauser==axx&trx),3,'omitnan');
                anSE(axx,:) = std(iFR_z(:,stimWin(e,(1)):stimWin(e,(2)),Mauser==axx&trx),0,3,'omitnan')/sqrt(sum(Mauser==axx&trx));
                
                % error propagation unit->animal->population
                %                                 anMean(ax,:) = mean(unMean(anUID==ax,:),1,'omitnan');
                %                                 anSE(ax,:) = sqrt(sum((unSE(anUID==ax,:)/sum(anUID==ax)).^2,1)); % corrected error propagation MArticus 240304
            end
            % error propagation
            M=mean(anMean,1,'omitnan');
            if sum(~isnan(anSE(:,1)))==1
                SE = anSE(~isnan(anSE(:,1)),:);
            else
                SE= sqrt(sum((anSE/size(anSE(~isnan(anSE(:,1)),:),1)).^2,1)); % corrected error propagation MArticus 240304
            end
            % No error propagation, taking the mean across all trials of
            % all units pooled together
            %             M =  mean(iFR_z(:,stimWin(e,(1)):stimWin(e,(2)),trx),3,'omitnan');
            %             SE = std(iFR_z(:,stimWin(e,(1)):stimWin(e,(2)),trx),0,3,'omitnan')/sqrt(sum(trx));
            
            
            boundedline(timevec{e},M,SE*1.96,'cmap',colorlabel{e,mx}{s},'alpha');
            if s==1&&mx==1
                hold on
            end                        
        end
    end
    
    xlabel('time(sec)')
    if e == 1
        ylabel('iFR z-scored');
    else
        yticklabels([])
        psax(e).YTickMode ='auto';
    end
    
    
    xlim([timevec{e}(1) timevec{e}(end)])
    title(epocStrs{e})    
end
% yLim = [-0.2 0.8];
if exist('yLim','var')
    if isempty(yLim)
        linkaxes(psax,'y')
    else
        set(psax,'YLim',yLim)
    end
else
    linkaxes(psax,'y')
end

set(0,'CurrentFigure',psf)
for e = 1:3
    currlegstr=[legstr{e,:}];
    currcolorlabel = [colorlabel{e,:}];
    chngleg(psax(e),currlegstr([1:2:end 2:2:end])',currcolorlabel([1:2:end 2:2:end]),fs);
end


stimBars = {{0 1.2},{0 1.2},{0}};
for s = 1:numel(stimBars)
    set(psf,'CurrentAxes',psax(s))
    yLimStim = ylim;
    if s==numel(stimBars)
        patch([stimBars{s}{1} stimBars{s}{1}+.1 stimBars{s}{1}+.1 stimBars{s}{1}],[yLimStim(2)-diff(yLimStim)*.05 yLimStim(2)-diff(yLimStim)*.05 yLimStim(2) yLimStim(2)],patchColor(2,:),'EdgeColor','none','FaceAlpha',1)
        
    else
        patch([stimBars{s}{[1 2]} stimBars{s}{[2 1]}],[yLimStim(2)-diff(yLimStim)*.05 yLimStim(2)-diff(yLimStim)*.05 yLimStim(2) yLimStim(2)],patchColor(1,:),'EdgeColor','none','FaceAlpha',1)
        
    end
end


%% add title
if ~isempty(Title)
    axes('Position',psf.Position.*[0 0 1 1],'Box','off','Color','none','YColor','none','XColor','none');
                    text(.5,1,Title,'FontSize',10,'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')
                    psf.Position = psf.Position+[0 0 0 .5];
                    psf.Children = psf.Children([2:end 1]);  
end
end

%% subfunction

function tmp=chngleg(ax,legstr,colorlabel,fs)
set(gcf,'CurrentAxes',ax)
if any(contains(legstr,'R'))
    tmppostxt = [ax.XLim(1)+diff(ax.XLim)*.8 ax.YLim(2)-diff(ax.YLim)*.01];
else
    tmppostxt = [ax.XLim(1)+diff(ax.XLim)*.05 ax.YLim(2)-diff(ax.YLim)*.01];
end
for lx = 1:size(legstr,1)
    tmp(lx) = text(tmppostxt(1),tmppostxt(2),legstr(lx,:),'Color',colorlabel{lx},'FontSize',fs,'Interpreter','tex');
    tmppostxt = tmppostxt -[0 diff(ax.YLim)*.1];
end
end
