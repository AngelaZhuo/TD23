% load(Cache + "/d_09_Apr_2024.mat") % it is 10GB so it takes a while

for u = 1:numel(d.clust_params)
    d.clust_params(u).session = convertCharsToStrings(d.clust_params(u).session);
end
for s = 1:numel(d.info)
    d.info(s).ID = convertCharsToStrings(d.info(s).ID);
    d.info(s).tag = convertCharsToStrings(d.info(s).tag);
end

SM = {};
ST = [];
TM = [];
EM = [];
Units = string([]);
UnitNames = [d.clust_params.session]';
for s = 1:numel(d.info)
    RealName = d.info(s).ID;
    Uner = find(UnitNames == RealName);
    if isempty(Uner); continue; end

    disd = d.clust_params(Uner);
    disSM = d.spikes(Uner);
    disMean = [disd.mean_fr]';
    Runer = [disd.region_coding]';
    Funcdan = ([disd.funcDAN_odorcue] + [disd.funcDAN_reward] + [disd.funcDAN_rewardcue])'>0;

    Nanner = ~ismember(Runer, [1, 2, 3]);
    Nanner = Nanner | ([disd.mean_fr]'<1);

    Uner(Nanner) = [];
    Runer(Nanner) = [];
    disd(Nanner) = [];
    disSM(Nanner) = [];
    disMean(Nanner) = [];

    mapper = d.events{d.map(Uner(1))};
    CS1 = [mapper.curr_odorcue_odor_num];
    CS2 = [mapper.curr_rewardcue_odor_num];
    US = [mapper.drop_or_not];
    disTM = permute(cat(1, CS1, CS2, US), [3, 1, 2]);
    disTM = repmat(disTM, numel(Uner), 1, 1);
    CS1_ = [mapper.fv_on_odorcue];
    CS2_ = [mapper.fv_on_rewcue];
    US_ = [mapper.reward_time];
    disST = permute(cat(1, CS1_, CS2_, US_), [3, 1, 2]);
    disST = repmat(disST, numel(Uner), 1, 1);

    disEM = string([]);
    disEM(1:size(disST,1), 1:4, 1:size(disST,3)) = "";
    Laser = d.laser(s);
    Laser = Laser{1};
    if numel(Laser)>2
        Timador = disST(1, :, :);
        Exciter = Laser{1};
        Inhibitor = Laser{2};
        Shammer = Laser{3};
        for tr = 1:150
            if ~isempty(Exciter)
                dex = any(Exciter>Timador(1, 1, tr) & Exciter<Timador(1, 1, tr)+1);
                if dex; disEM(:, 1, tr) = "E"; continue; end
                dex = any(Exciter>Timador(1, 1, tr)+1.1 & Exciter<Timador(1, 1, tr)+2.3);
                if dex; disEM(:, 2, tr) = "E"; continue; end
                dex = any(Exciter>Timador(1, 2, tr) & Exciter<Timador(1, 2, tr)+1);
                if dex; disEM(:, 3, tr) = "E"; continue; end
                dex = any(Exciter>Timador(1, 2, tr)+1.1 & Exciter<Timador(1, 2, tr)+2.3);
                if dex; disEM(:, 4, tr) = "E"; continue; end
            end

            if ~isempty(Inhibitor)
                din = any(Inhibitor>Timador(1, 1, tr) & Inhibitor<Timador(1, 1, tr)+1);
                if din; disEM(:, 1, tr) = "I"; continue; end
                din = any(Inhibitor>Timador(1, 1, tr)+1.1 & Inhibitor<Timador(1, 1, tr)+2.3);
                if din; disEM(:, 2, tr) = "I"; continue; end
                din = any(Inhibitor>Timador(1, 2, tr) & Inhibitor<Timador(1, 2, tr)+1);
                if din; disEM(:, 3, tr) = "I"; continue; end
                din = any(Inhibitor>Timador(1, 2, tr)+1.1 & Inhibitor<Timador(1, 2, tr)+2.3);
                if din; disEM(:, 4, tr) = "I"; continue; end
            end

            if ~isempty(Shammer)
                dsh = any(Shammer>Timador(1, 1, tr) & Shammer<Timador(1, 1, tr)+1);
                if dsh; disEM(:, 1, tr) = "S"; continue; end
                dsh = any(Shammer>Timador(1, 1, tr)+1.4 & Shammer<Timador(1, 1, tr)+2.4);
                if dsh; disEM(:, 2, tr) = "S"; continue; end
                dsh = any(Shammer>Timador(1, 2, tr) & Shammer<Timador(1, 2, tr)+1);
                if dsh; disEM(:, 3, tr) = "S"; continue; end
                dsh = any(Shammer>Timador(1, 2, tr)+1.4 & Shammer<Timador(1, 2, tr)+2.4);
                if dsh; disEM(:, 4, tr) = "S"; continue; end
            end
        end
    end

    Adder = ["", convertCharsToStrings(d.info(s).animal) + "_" + convertCharsToStrings(d.info(s).tag_ncount), d.info(s).animal, d.info(s).tag_ncount, "", "", ""];
    Adder = repmat(Adder, numel(Uner), 1);
    Adder(:,1) = string(Uner);
    Adder(:, 5) = Runer;
    Adder(:, 6) = disMean;
    Adder(:, 7) = s.*ones(size(disMean,1),1);

    Units = cat(1, Units, Adder);
    SM = cat(1, SM, disSM');
    ST = cat(1, ST, disST);
    TM = cat(1, TM, disTM);
    EM = cat(1, EM, disEM);
    s
end
Units = array2table(Units);
Units.Properties.VariableNames = [{'Unit'}, {'Name'}, {'Mouse'}, {'Session'}, {'Region'}, {'MeanFR'}, {'s'}];
Units.Unit = double(Units.Unit);
Units.Session = double(Units.Session);
Units.Region = double(Units.Region);
Units.MeanFR = double(Units.MeanFR);
Units.s = double(Units.s);
%% Create iFR_Angela_TD23
iFR = NaN(size(Units,1), 128, 150); % 15.8 seconds

Kernel = 3000 % 300ms
pd = makedist('HalfNormal','mu',0,'sigma',Kernel);
pdf1 = pdf(pd, 0:Kernel.*6);
Sample = 1000; % 1000ms
ScaleBy = 10000;
Time = (-Kernel.*6):(12.8.*ScaleBy + Kernel.*6);
parfor u = 1:size(Units,1)
    SM_ = int64(SM{u}.*ScaleBy);
    ST_ = int64(ST(u, :, :).*ScaleBy);
    ifr = NaN(1, 128, 150);
    for tr = 1:150
        trial = ST_(1, 1, tr);
        trial = SM_ - trial + int64(2.*ScaleBy); trial(trial<-Kernel.*6) = []; 
        trial(trial>int64(12.8.*ScaleBy)) = [];
        if isempty(trial); ifr(1, :, tr) = 0; continue; end
        IFR = zeros(size(Time));
        for s = 1:numel(trial)
            IFR(trial(s)+Kernel.*6+1:trial(s)+Kernel.*6 +1 + Kernel.*6) = IFR(trial(s)+Kernel.*6+1:trial(s)+Kernel.*6 +1 + Kernel.*6) + pdf1; 
        end
        IFR = IFR(Kernel.*6+1:Sample:end - Kernel.*6 -1);
        ifr(1, :, tr) = IFR.*ScaleBy;
    end
    iFR(u, :, :) = ifr;
    u
end     
Events = [21, 33, 45, 45, 57, 70, 128];

Namer = unique(Units.Name);
TM_sessions = NaN(max(Units.s), size(TM,2), size(TM,3));
for na = 1:numel(Namer)
    disU = find(Units.Name==Namer(na));
    disTM = TM(disU(1), :, :);

    TM_sessions(Units.s(disU(1)), :, :) = disTM;
end
save(Cache + "iFR_Angela_300ms.mat", "iFR", "TM", "TM_sessions", "EM", "Events", "Units", "-v7.3");