%% 20240502 TD23 AZ
% Investigate why the d1-msns that get excited/inhibited in the manip sessions did not show up as tagged units in KS3
% Only units from x04, x07-x10 (good learners) were investigated
% Modified from VPunit_check.m
% First find all the units that gets inhibited or excited by the laser/LED pulse
% Load d-struct and iFR
animals = ["x0" + string([4 7:9]) "x10"];
utypes = "Pmsn";

X = ["cs1_silence" "cs2_silence" "cs1delay_silence" "cs2delay_silence" "excitea" "exciteb"];
saveDir = "/zi-flstorage/data/Angela/DATA/TD23/Plots/UnitInfo/d1_tag_prob/not_d1_tagged/";


for xx = 5:numel(X)  %First focus on the excitation sessions
    uids = UnitSelectionMod(d,"X("+X(xx)+")"+utypes+"Animals("+strjoin(animals,',')+")");
    %remove units that are already marked as d1_tagged  
    uids([d.clust_params.d1_tagged]==1) = false; 
    uids = find(uids);
    %Test unit response to laser
    uresp = getUnitsLaserResponseTD23(d,uids);
    % Get units with significant resposne to manipulation
    if contains(X(xx),'silence')
       u2invest = uids(uresp==-1);
    else
       u2invest = uids(uresp==1);
    end
    for ux = 1:numel(u2invest)
%         set(groot,'DefaultFigureVisible',0)
        curUnit = u2invest(ux);
        spxtimes = d.spikes{1,curUnit};
        curr_tag = d.info(d.map(curUnit)).tag;
        if contains(curr_tag, 'cs1','IgnoreCase',true)
            trTypes = 1:8;
            stimWin = 'fv_on_odorcue';
        elseif contains(curr_tag, 'cs2','IgnoreCase',true)
            trTypes = 1:8;
            stimWin = 'fv_on_rewcue';
        elseif contains(curr_tag, 'excitea','IgnoreCase',true)
            trTypes = 1:4;
            stimWin = 'fv_on_odorcue';
        elseif contains(curr_tag, 'exciteb','IgnoreCase',true)
            trTypes = 5:8;
            stimWin = 'fv_on_odorcue';
        end
    
        if contains(curr_tag,'silence','IgnoreCase',true)
            manipStr = 'inhibit_or_not';
        else
            manipStr = 'excite_or_not';
        end
        events = d.events{1,d.map(curUnit)};
        events(~ismember([events.curr_trialtype],trTypes)) = [];
        trialtimes = [events.(stimWin)];


        titleStr = [d.clust_params(curUnit).animal,'_',d.clust_params(curUnit).date,...
        '. Unit Nr. ',num2str(curUnit),' Tetrode Nr. ',num2str(d.clust_params(curUnit).tetrode)];
    
    
    %Plot cross-correlograms
        [crosstag_ex, crossinfo, fex] = XcorrExcite(d,curUnit,1);  %cross-correlation from the excitation led/laser during the session
        drawnow
        [crosstag, taginfo, fh] = CrossTagTD23(d,curUnit,1);  %cross-correlation from the the tagging  
        
    %Plot scatter and PSTH for laser and sham trials separately
        ps = figure('Position',[1 12 7.5 7.5]);
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
        
        %Unit PSTH from iFR laser vs. sham
        psf = PSTHfromiFR(d,iFR,curUnit,TM,'manipulation',{0 1});
        
        %Combine plots
        cf = univCombFig([fex,ps,fh,psf],[2 2],1);  %problem with copyobj in CombineFigures.m 
        axes('Position',cf.Position.*[0 0 1 1],'Box','off','Color','none','YColor','none','XColor','none');
        text(.5,1,string(curr_tag)+" "+utypes+ string(titleStr),'FontSize',7,'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')
        cf.Position =cf.Position+[0 0 0 .5];
        cf.Children = cf.Children([2:end 1]);
        
        %save the plot in saveDir
        exportgraphics(cf,saveDir+string(curr_tag)+"_"+string(d.clust_params(curUnit).animal)+"_Unit"+string(curUnit)+".png",'Resolution',300)
        
        close all
        clc
    end
end 

