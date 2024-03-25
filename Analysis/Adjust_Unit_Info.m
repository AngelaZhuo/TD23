%% Adjust ChannelMapAZ and d.clust_params according to histology

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
% for unix = 1:size(d.clust_params,1)
%     if strcmp(d.clust_params(unix).animal,animals(ax))
%         d.clust_params(unix).region_coding = ChannelMapAZ.(animals(ax)).region(d.clust_params(unix).tetrode);
%         d.clust_params(unix).antshift = ChannelMapAZ.(animals(ax)).antshift(d.clust_params(unix).tetrode);
%         d.clust_params(unix).medlat = ChannelMapAZ.(animals(ax)).medlat(d.clust_params(unix).tetrode);
%     else
%         d.clust_params(unix).antshift = NaN;
%         d.clust_params(unix).medlat = NaN;
%     end
% end

save (['/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/d_' date '.mat'],'d','-v7.3')




