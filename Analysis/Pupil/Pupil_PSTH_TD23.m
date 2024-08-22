%% Create PSTH plots for pupil TD23
%20240820, modified from PSTHfromiFR.m

%input: load clean_pupil.mat, which contains M, TM, Pump, Events and Namer 
%input: M, animal in string (ex. "x08" or "all"), ses_tag (ex."exciteA" or "all")
% Events [CS1, CS2, US] in 100ms bin
% M is pupil matrix with dimensions 404 (sessions) x 179 (bins) and 150 (trials) 
% Namer - 1st column: animal-session, 2nd column: animal, 3rd column:tag_ncount, 4th column: session# in d.info, 5th column: session tag
% TM - trial matrix, 1st column: CS1 odor, 2nd column: CS2 odor, 3rd column: US, 4th column: inhibit/excite or not
% Pump is 404 double array of which pump was used that session: either 1 or 2 

% load '/zi-flstorage/data/Angela/DATA/TD23/Matrices/Clean_Pupil.mat'


function Pupil_PSTH_TD23(M,Namer,Events,TM,Pump,animal,ses_tag,varargin)

% set(groot,'DefaultFigureVisible','off')

if strcmp(animal,"all")
    animal = ["x0" + string(1:9) "x10"];
end
if strcmp(ses_tag,"all")
    ses_tag = unique(Namer(:,5))';
end
sessions = find(ismember(Namer(:,2),animal) & ismember(Namer(:,5),ses_tag));

figs = [15 5]; % heatmap; psth & eucleadian
fs = 6; %fontsize
ps = [figs(1)*.225 figs(2)*.675;...
    figs(1)*.225 figs(2)*.675;...
    figs(1)*.45 figs(2)*.675];

binsize = 0.1; %sec diff(stimWin)/binsize has to be integer
patchColor = [.7 .7 .7;.9 0 0];

if any(contains(varargin(1:2:end),'manipulation'))
   Manip = varargin{find(contains(varargin(1:2:end),'manipulation'))*2};
else    
   Manip = {0:1};
end

if any(contains(varargin(1:2:end),'title'))
    Title = varargin{find(contains(varargin(1:2:end),'title'))*2};
else
    Title = [];
end

for sid = 1:numel(sessions)
    ses_curr = sessions(sid);
    para = Namer(ses_curr,5);
    Events = round(Events);
    Title = Namer(ses_curr,3)+ "_" +ses_tag + "_" + Namer(ses_curr,2);

    %stimWin needs to be integers
    stimWin(1,:) = [Events(1)-10 Events(1)+24];
    timevec{1} = -1:binsize:diff(stimWin(1,:)*binsize)-1;
    stimWin(2,:) = [Events(2)-10 Events(2)+24];
    timevec{2} = -1:binsize:diff(stimWin(2,:)*binsize)-1;
    if Pump(ses_curr) == 1
        stimWin(3,:) = [Events(3)-10-3 Events(3)+59-3];  %Adjust all rew_time to be -3bins(-0.29s) for pump1 
        timevec{3} = -1:binsize:diff(stimWin(3,:)*binsize)-1;
    elseif Pump(ses_curr) == 2
        stimWin(3,:) = [Events(3)-10 Events(3)+59]; %Unchanged rew_time as +0.4bin(0.04s) doesn't alter the integer 
        timevec{3} = -1:binsize:diff(stimWin(3,:)*binsize)-1; 
    end

    if numel(Manip)==1&&~all(Manip{1}==1)
       states = [1 2 2]; 
    else
        states = [1 1 1];
    end

    epocStrs ={'CS1','CS2','US'};

    psf = figure('Position',[1 1 figs]);
    Mslct = M(ses_curr,:,:);
    TMslct = TM(ses_curr,:,:);
    TMslct(TMslct==10)=6;
    
    % Normalized to baseline
    Baseline = mean(Mslct(:,1:Events(1)-1,:),2,"omitnan"); %4s baseline
    Mslct = Mslct./Baseline;
    
    % z-score pupil matrix
    M_z = (Mslct-mean(Mslct,'all','omitnan'))/std(Mslct,0,'all','omitnan');
    
    for e = 1:3
        psax(e) = axes('Position',[1+(e-1)*.225+ps(1,1)*(e -1) 1 ps(e,:)]);
        
        for mx = 1:numel(Manip)  %first plot sham, then manip trials
            [colorlabel{e,mx},legstr{e,mx},code] = get_colegcode(epocStrs{e},states(e),'manipulation',Manip{mx},'paradigm',para);
            for s = 1:size(code,1)
                anMean = NaN(1, numel(timevec{e}));
                anSE = NaN(1, numel(timevec{e}));
                trx = squeeze(PSTHindex(TMslct,code(s,:),Manip{mx}));
                 %Select matching trial types
                anMean(1,:) = mean(M_z(:,stimWin(e,(1)):stimWin(e,(2)),trx),3,'omitnan');
                anSE(1,:) = std(M_z(:,stimWin(e,(1)):stimWin(e,(2)),trx),0,3,'omitnan')/sqrt(sum(trx));
                % error propagation
                M_anMean = mean(anMean, 1, 'omitnan');
                if sum(~isnan(anSE(:,1)))==1
                    SE = anSE(~isnan(anSE(:,1)),:);
                else
                    SE= sqrt(sum((anSE/size(anSE(~isnan(anSE(:,1)),:),1)).^2,1)); % corrected error propagation MArticus 240304
                end
                
                boundedline(timevec{e},M_anMean,SE*1.96,'cmap',colorlabel{e,mx}{s},'alpha');
                
                if s==1&&mx==1
                    hold on
                end
            end
        end
        xlabel('time(sec)')
        if e == 1
            ylabel('pupil diam z-scored');
        else
            yticklabels([])
            psax(e).YTickMode ='auto';
        end
    
    
        xlim([timevec{e}(1) timevec{e}(end)])
        title(epocStrs{e}) 
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
    
        %% add title and save image
    if ~isempty(Title)
        axes('Position',psf.Position.*[0 0 1 1],'Box','off','Color','none','YColor','none','XColor','none');
                        text(.5,1,Title,'FontSize',10,'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')
                        psf.Position = psf.Position+[0 0 0 .5];
%                         psf.Children = psf.Children([2:end 1]);  %Reorder the children changes the axis limits   
    end
    
    saveas(gcf,"/zi-flstorage/data/Angela/DATA/TD23/Pupil/plots/PSTH/animal/zscore_tag_" + Namer(ses_curr,3) + "_" + Namer(ses_curr,2)+ ".png")
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

% Loop over sessions
% for id = 1:numel(Namer)
%     clf
%     M_ = M(id,:,:);
%     Baseline = mean(M_(:,1:Events(1)-1,:),2,"omitnan"); %4s baseline
%     M_ = M_./Baseline;
%     M_ = zscore_xnan(M_);  %compute the z-score without the NaN values
%     TM_ = TM(id,:,:);
%     Mirko_TD23(M_, TM_, [Events(1), Events(1)+12, Events(2)-1, Events(2), Events(2)+12, Events(3), size(M,2)-1], "zscore", 0, 0)
%     title("s = " + Namer(id,3) + ", animal = " + Namer(id,2))
%     parsave_img("/zi-flstorage/data/Angela/DATA/TD23/Pupil/plots/PSTH/animal", "zscore_s_" + Namer(id,3) + "_" + Namer(id,2), 0, 1, 0)
% end