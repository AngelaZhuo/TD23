%% 240402 TD23
%% find units with unexpected responding to laser
% Cases of to look for
% - pMSN excited by silencing
% - pMSN inhibited by stimulation (exciteA and exciteB)
% - Only units from x04, x07-x10 (good learners) were investigated
function InvestigateUnexcpectedLaserResponses(d,iFR)

animals = ["x0" + string([4 7:9]) "x10"];
X = ["cs1_silence" "cs2_silence" "cs1delay_silence" "cs2delay_silence" "excitea" "exciteb"];
utypes = "Pmsn";
TM = getTM(d);
susUnits = [17026 17052 29248 29267 33000 33883 35103 40313 40317 43166 44071 47451 47461 47464 16298 17114];
saveDir = "/zi-flstorage/data/Mirko/TD23/Plots/EPhys/Units/manipulation effects/unexpectedResponseUnits/";

for xx = 4:numel(X)
    % paradigm specific parameters
    if contains(X(xx), 'cs1')
        trTypes = 1:8;
        stimWin = 'fv_on_odorcue';
    elseif contains(X(xx), 'cs2')
        trTypes = 1:8;
        stimWin = 'fv_on_rewcue';
    elseif contains(X(xx), 'excitea')
        trTypes = 1:4;
        stimWin = 'fv_on_odorcue';
    elseif contains(X(xx), 'exciteb')
        trTypes = 5:8;
        stimWin = 'fv_on_odorcue';
    end
    
    for utx = 1:numel(utypes)
        % Get units
        uids = find(UnitSelectionMod(d,"X("+X(xx)+")"+utypes(utx)+"Animals("+strjoin(animals,',')+")"));
        % Test units response to laser
        uresp = getUnitsLaserResponseTD23(d,uids);
        % Get units with unexpected response
        if contains(X(xx),'silence')
            manipStr = 'inhibit_or_not';
            u2invest = uids(uresp==1);
        else
            manipStr = 'excite_or_not';
            u2invest = uids(uresp==-1);
        end
        
        %% investigate units
        for ux = 1: numel(u2invest)
            set(groot,'DefaultFigureVisible',0)
            curUnit = u2invest(ux);
            spxtimes = d.spikes{1,curUnit};
            
            events = d.events{1,d.map(curUnit)};
            events(~ismember([events.curr_trialtype],trTypes)) = [];
            trialtimes = [events.(stimWin)];
            
            
            titleStr = [d.clust_params(curUnit).animal,'_',d.clust_params(curUnit).date,...
                '. Unit Nr. ',num2str(curUnit),' Tetrode Nr. ',num2str(d.clust_params(curUnit).tetrode)];
            
            %% plot
            % unit info plot
            ui = plot_unitInfo(spxtimes,d.clust_params(curUnit).wf,[1 24 20 10]);
%             axes('Position',ui.Position.*[0 0 1 1],'Box','off','Color','none','YColor','none','XColor','none');
%             text(.4,.975,titleStr,'FontSize',6,'FontWeight','bold','Interpreter','none')
            
            % scatter and psth for laser and sham trials separately
            ps = figure('Position',[1 12 10 10]);
            for mx = 0:1
                curr_trialtimes = trialtimes([events.(manipStr)]==mx);
                mpsth_pj_x(spxtimes,curr_trialtimes,'pre', 1000, 'post',2400 , 'binsz',...
                    100, 'tb', 1, 'chart', 2,'fr',1,...
                    'subplots',[2, 2,mx+3; 2, 2, mx+1]);
                if ~mx
                    title('sham')
                else
                    title('laser')
                end
                
            end
            linkaxes(ps.Children([2 4]))
            
            % units psth from iFR laser vs sham
            psf = PSTHfromiFR(d,iFR,curUnit,TM,'manipulation',{0 1});
            
            % combine plots
            cf = univCombFig([psf ui ps],[3 1],1);
            axes('Position',cf.Position.*[0 0 1 1],'Box','off','Color','none','YColor','none','XColor','none');
            text(.4,.99,{X(xx)+" "+utypes(utx);titleStr},'FontSize',12,'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')
            cf.Position =cf.Position+[0 0 0 .5];
            cf.Children = cf.Children([2:end 1]);
            
            susLog = input('Unit suspicious?');
            
            if susLog
                exportgraphics(cf,saveDir+X(xx)+"_"+string(d.clust_params(curUnit).animal)+"_Unit"+string(curUnit)+".png",'Resolution',300)
                susUnits = [susUnits curUnit];
            end
            close all
            clc
        end
    end
end
end