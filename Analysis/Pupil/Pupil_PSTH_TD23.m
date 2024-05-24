%% Loop to create pupil PSTH - TD23
%20240404, modified from PSTH_Loop.m(TD22)

clear
load '/zi-flstorage/data/Angela/DATA/TD23/Matrices/Clean_Pupil.mat'

Events = int64(Events);

for id = 1:106
    clf
    M_ = M(id,:,:);
    Baseline = mean(M_(:,1:Events(1)-1,:),2,"omitnan"); %4s baseline
    M_ = M_./Baseline;
    M_ = zscore_xnan(M_);  %compute the z-score without the NaN values
    TM_ = TM(id,:,:);
    Mirko_TD23(M_, TM_, [Events(1), Events(1)+12, Events(2)-1, Events(2), Events(2)+12, Events(3), size(M,2)-1], "zscore", 1, 0)
    title("s = " + Namer(id,3) + ", animal = " + Namer(id,2))
    parsave_img("/zi-flstorage/data/Angela/DATA/TD23/Pupil/plots/PSTH/animal", "zscore_s_" + Namer(id,3) + "_" + Namer(id,2), 0, 1, 0)
end