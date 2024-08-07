%% Adjust ChannelMapAZ and d.clust_params according to histology
%20240323
%Only modify the d.clust_params for the learned animals: x04, x07-x10
%Changed the region for useless tetrodes to 99
%antshift(in VS, 0 is post, 1 is ant; in VTA, 0 is inside the region, 1 is outside; 99 is for tetrodes with no units)
%medlat(in VS, 1 is medial, 2 is lateral; in VTA, all is 0; 99 is for tetrodes with no units)


load ('/home/yi.zhuo/Documents/Github/KS3_Pipeline/TD23/ChannelMapAZ.mat')

%Tetrodes to be removed: x04 (20, 33); x07(18, 36); x08(6, 16, 17, 18, 24, 26, 29, 32)
%x09(17, 19);x10(21, 24, 26, 29, 30)

%x04 - all NAc tetrodes are post; all Tu tetrodes are ant; all VTA tetrodes are out  
ChannelMapAZ.x04.antshift(1:16) = 0;
ChannelMapAZ.x04.antshift(17:48) = 1;
ChannelMapAZ.x04.antshift([20,33]) = 99;
ChannelMapAZ.x04.medlat([4:6,9,10,14:19,23,24,27:29]) = 2; %lateral
ChannelMapAZ.x04.medlat([1:3,7,8,11:13,21:22,25,26,30:32])=1; %medial
ChannelMapAZ.x04.medlat(33:48)=0; %VTA
ChannelMapAZ.x04.medlat([20,33])=99;
ChannelMapAZ.x04.region([20,33])=99;

%x07 - all Tu tetrodes are ant
ChannelMapAZ.x07.antshift([9:16,33:48]) = 0;
ChannelMapAZ.x07.antshift([1:8,17:32]) = 1;
ChannelMapAZ.x07.antshift([18,36]) = 99;
ChannelMapAZ.x07.medlat([4:6,9,10,14:19,23,24,27:29]) = 2;
ChannelMapAZ.x07.medlat([1:3,7,8,11:13,20:22,25,26,30:32]) = 1;
ChannelMapAZ.x07.medlat(33:48)=0; %VTA
ChannelMapAZ.x07.medlat([18,36]) = 99;
ChannelMapAZ.x07.region([18,36])=99;


%x08 - all NAc/Tu tetrodes are ant
ChannelMapAZ.x08.antshift(1:32) = 1;
ChannelMapAZ.x08.antshift(33:48) = 0;
ChannelMapAZ.x08.antshift([6,16:18,24,26,29,32]) = 99;
ChannelMapAZ.x08.medlat([4:6,9,10,14:19,23,24,27:29]) = 2;
ChannelMapAZ.x08.medlat([1:3,7,8,11:13,20:22,25,26,30:32]) = 1;
ChannelMapAZ.x08.medlat([6,16:18,24,26,29,32]) = 99;
ChannelMapAZ.x08.medlat(33:48)=0; %VTA
ChannelMapAZ.x08.region([6,16:18,24,26,29,32]) = 99;


%x09 - All NAc tetrodes are post, all OT tetrodes are ant
ChannelMapAZ.x09.antshift([1:16,33:48])=0;
ChannelMapAZ.x09.antshift(17:32)=1;
ChannelMapAZ.x09.antshift([17,19])=99;
ChannelMapAZ.x09.medlat([4:6,9,10,14:19,23,24,27:29]) = 2;
ChannelMapAZ.x09.medlat([1:3,7,8,11:13,20:22,25,26,30:32]) = 1;
ChannelMapAZ.x09.medlat(33:48)=0; %VTA
ChannelMapAZ.x09.medlat([17,19])=99;
ChannelMapAZ.x09.region([17,19])=99;


%x10 - all VTA tetrodes are out  
ChannelMapAZ.x10.antshift([9,10,11:16,23,24,27:32])=0;
ChannelMapAZ.x10.antshift([1:8,17:22,25,26,33:48])=1;
ChannelMapAZ.x10.antshift([21,24,26,29,30])=99;
ChannelMapAZ.x10.medlat([4:6,9,10,14:19,23,24,27:29])=2;
ChannelMapAZ.x10.medlat([1:3,7,8,11:13,20:22,25,26,30:32])=1;
ChannelMapAZ.x10.medlat(33:48)=0;
ChannelMapAZ.x10.medlat([21,24,26,29,30])=99;
ChannelMapAZ.x10.region([21,24,26,29,30])=99;


save ('/home/yi.zhuo/Documents/Github/KS3_Pipeline/TD23/ChannelMapAZ.mat','ChannelMapAZ')


%% Loop over d.clust_params to fill in the info
%20240324

load ('/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/d_15-Mar-2024.mat')
load ('/home/yi.zhuo/Documents/Github/KS3_Pipeline/TD23/ChannelMapAZ.mat')

clearvars -except d ChannelMapAZ

animals = ["x0" + string([4,7:9]),"x10"];

[d.clust_params.medlat] = deal(nan);  %set all the values to NaN
[d.clust_params.antshift] = deal(nan);
units_of_interest = find(contains({d.clust_params.animal},animals));

for un = 1:numel(units_of_interest)
    unid = units_of_interest(un);
    ax = find(strcmp(d.clust_params(unid).animal,animals));
    d.clust_params(unid).region_coding = ChannelMapAZ.(animals(ax)).region(d.clust_params(unid).tetrode);
    d.clust_params(unid).antshift = ChannelMapAZ.(animals(ax)).antshift(d.clust_params(unid).tetrode);
    d.clust_params(unid).medlat = ChannelMapAZ.(animals(ax)).medlat(d.clust_params(unid).tetrode);
end


save (['/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/d_' date '.mat'],'d','-v7.3')


%sanity check
reg99 = find([d.clust_params.region_coding]==99);
for reg = 1:numel(reg99)
    unid99 = reg99(reg);
    animal99{reg} = d.clust_params(unid99).animal;
    tetrode99{reg} = d.clust_params(unid99).tetrode;
end


%% Add pump info to the d-struct
%20240402

% load ('/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/d_24-Mar-2024.mat')

clearvars -except d

[d.info.pump] = deal(nan);
PMC_sessions = d.info(contains({d.info.tag},{'PMC','silence','excite'}));
dates = unique({PMC_sessions.date});

for ses = 1:size(d.info,2)
    doi = find(strcmp(d.info(ses).date,dates));
    if ~isempty(doi)
        if ismember(doi,[1 3 6 7 9 10 12 13 15 17 19 22 24 26 28 30 32 34 36 38 40])
            d.info(ses).pump = 1;
        else
            d.info(ses).pump = 2;
        end
    end
end

save (['/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/d_' date '.mat'],'d','-v7.3')

%% Adjust the reward time for pump1
%20240408
%Align all the reward_time to the reward pump drop latency of that day session
%Pump1 has a 230ms delay between pump_on and water drop at the lickport; Pump2 has a 560ms delay between the pump_on and water drop at lick port
%The drop_latency taken in the past was 520ms, so if it's pump1 as R pump, -290ms to the reward_time; if pump2 is the R pump, +40ms to the reward_time 

load ('/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/d_02-Apr-2024.mat')
% old_d = d;
new_d = d;

for ses = 1:size(d.events,2)
    if d.info(ses).pump == 1
        for tr = 1:numel(d.events{1,ses})
        new_d.events{1,ses}(tr).reward_time = d.events{1,ses}(tr).reward_time-0.29; %in seconds
        end
    elseif d.info(ses).pump == 2
        for tr = 1:numel(d.events{1,ses})
        new_d.events{1,ses}(tr).reward_time = d.events{1,ses}(tr).reward_time+0.04; 
        end
    end
end

%% Mark putative ventral pallidum (pVP) units as region = 4

VP_units = [17026,17052,29248,29267,33000,33883,35103,40313,40317,47451,47461,47464,43166,16164,16775,29396,33169,33181,33184,33676,33681,34175,39582,39583,39589,39591,40111,40133,40135,43250,43264,16298,17114,29048,29057,33369,34437,34720,34722,38993,39487,39491,40003,40004,43330,43334,43998,44202,44207,40437,40687,18213,41527,41901,45949,18425,41173,41769,41794,45432]; 
% It's important to keep the same index in the d.clust_params

for vp = 1:numel(VP_units)
    new_d.clust_params(VP_units(vp)).region_coding = 4;
end


%%
clearvars -except new_d

d = new_d;

save (['/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/d_' date '.mat'],'d','-v7.3')


%% Replace the "tag" field in d.clust_params with "tag" from d.info
%20240807

for ux = 1:numel(d.clust_params)
    
    d.clust_params(ux).tag = d.info(d.map(ux)).tag;
    
end
