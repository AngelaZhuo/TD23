%% Check whether the units in pVP-containing tetrodes are also VP units

%/zi-flstorage/data/Mirko/TD23/Plots/EPhys/Units/manipulation effects/unexpectedResponseUnits
VP_units = [17026,17052,29248,29267,33000,33883,35103,40313,40317,47451,47461,47464,43166,16164,16775,29396,33169,33181,33184,33676,33681,34175,39582,39583,39589,39591,40111,40133,40135,43250,43264,16298,17114,29048,29057,33369,34437,34720,34722,38993,39487,39491,40003,40004,43330,43334,43998,44202,44207,40437,40687,18213,41527,41901,45949,18425,41173,41769,41794,45432]; 
% load ('/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/d_09-Apr-2024.mat')
% load ('/zi-flstorage/data/Angela/DATA/TD23/Matrices/iFR(d_09-Apr-2024)/iFR_causal_andRest_300ms.mat')
% Plot all the units from the pVP-containing tetrodes from the same day-session (to avoid having too many plots) 
saveDir = "/zi-flstorage/data/Angela/DATA/TD23/Plots/UnitInfo/VP-containing-tetrodes/x08tet13/";
utypes = "Pmsn";
U2invest_total = [];

for vp = 1:numel(VP_units)
    animal{vp} = convertCharsToStrings(d.clust_params(VP_units(vp)).animal);
    tetrode{vp} = d.clust_params(VP_units(vp)).tetrode;
    tag{vp} = d.info(d.map(VP_units(vp))).tag;
    tag_ncount{vp} = d.info(d.map(VP_units(vp))).tag_ncount;
    date{vp} = d.clust_params(VP_units(vp)).date;
    U2invest = find(UnitSelectionMod(d,utypes +"Animal("+animal(vp)+")"+"Tx("+tetrode(vp)+")"+"Sct("+tag_ncount(vp)+")"));
    U2invest_total = [U2invest_total;U2invest];
end

U2invest_total = unique(U2invest_total);

%%
for ux = 1: numel(U2invest_total)
    set(groot,'DefaultFigureVisible',0)
    curUnit = U2invest_total(ux);
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

    %% plot
    % unit info plot
    ui = plot_unitInfo(spxtimes,d.clust_params(curUnit).wf,[1 24 15 7.5]);
    drawnow
%             axes('Position',ui.Position.*[0 0 1 1],'Box','off','Color','none','YColor','none','XColor','none');
%             text(.4,.975,titleStr,'FontSize',6,'FontWeight','bold','Interpreter','none')

    % scatter and psth for laser and sham trials separately
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

    % units psth from iFR laser vs sham
    psf = PSTHfromiFR(d,iFR,curUnit,TM,'manipulation',{0 1});
%     ScaleFigure(psf,.75);

    % combine plots
    cf = univCombFig([psf ui ps],[3 1],1);
    axes('Position',cf.Position.*[0 0 1 1],'Box','off','Color','none','YColor','none','XColor','none');
    text(.5,1,string(curr_tag)+" "+utypes+ string(titleStr),'FontSize',7,'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')
    cf.Position =cf.Position+[0 0 0 .5];
    cf.Children = cf.Children([2:end 1]);

%     susLog = input('Unit suspicious?');
    

%     if susLog
    exportgraphics(cf,saveDir+string(curr_tag)+"_"+string(d.clust_params(curUnit).animal)+"_Unit"+string(curUnit)+".png",'Resolution',300)
%         susUnits = [susUnits curUnit];
%     end
    close all
    clc
end

%%
% animals = ["x0" + string([4 7:9]) "x10"];
% for an = 1:numel(animals)
%     Unit_perAnimal(an) = numel(find(contains(string(animal),animals{an})));
%     tetrode_perAnimal{an} = unique(cell2mat(tetrode(contains(string(animal), animals{an}))));
% end




