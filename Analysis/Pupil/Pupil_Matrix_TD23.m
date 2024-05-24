%% Total pipeline
%Modified from Pupil_Matrx.m in TD22 folder
% clear
PVdirectory = "/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3";
addpath(genpath(PVdirectory))
% Functions_directory = "/home/yi.zhuo/Documents/Github/TD22/Analysis/Pupil/Master_GLM"; addpath(genpath(Functions_directory))
% cd(Functions_directory)

%Load the d-struct
% load("d_16-May-2024.mat") % You might need to update this line
clearvars -except d
PVsmall = d;
Regions = ["Pupil"];
Sessions = numel(PVsmall.info);

%Index of the Sesser is the order of the PMC session (tag_ncount), index 1 is the first 150-trial session 14.06.2023
%Sesser(x) contains all the d.info indices of the day session

for s = 1:14
        Sesser{s} = [1:10] + (s-1)*10;
end

Sesser{15} = [151:160];

for s = 16:41
        Sesser{s} = [171:180] + (s-16)*10;
end

Events = [41];
Events([2, 3]) = [Events(1) + 24.4, Events(1) + 24.4 + 24.4];  %Event time in ms in one trial;begginning of CS1,CS2 and US

Namer = string([]); 
Pupil = [];
TM = [];
Pump = [];

for s = 1:41  %loop over tag_ncount
    teil = 1;
    Matrices.(Regions{teil}).matrix =[];
    Matrices.(Regions{teil}).trialMatrix =[];
    Matrices.(Regions{teil}).jitter = [];
    Matrices.(Regions{teil}).mouse = [""];
    Matrices.(Regions{teil}).events = Events;
    uu = 0;
    for u = Sesser{s} %loop over all animal-day sessions
        Adder = [convertCharsToStrings(PVsmall.info(u).animal) + "_" + s, convertCharsToStrings(PVsmall.info(u).animal), s, u];
        pump = PVsmall.info(u).pump;
    %     diam = PVsmall.pupil(u).raw_trace;
        diam = PVsmall.pupil(u).aligned_trace;
        diam(diam == 0) = NaN;
        if isempty(diam) || all(isnan(diam)); warning(['diam of sesser ', num2str(u), ' is defective']); continue; end
        uu = uu+1;
        BinSize = .100; %Seconds
        diamTime = (1:numel(diam)).*BinSize;

        Session = PVsmall.events(u); Session = Session{1};
        Trials = size(Session, 2); % Compare with PVsmall.TrialMatrix(UnitIndex(u), :, :);
%         if Trials == 140; Session(126:end) = []; Trials = 125; end    %Y07 and Y08 on 20220917, FV crashed at Trial 126
        TotalTime = Session(Trials).reward_time + 10;

        diamTime(diamTime>TotalTime) = [];
        diam(numel(diamTime)+1:end) = [];
        for tr = 1:Trials
            
        % TD_23 - CS1, CS2 and US have a maximum jitter of 0.3 ms, which we neglect because it is much smaller than our resolution of 100ms
        % True odor duration is ~ 1.244s and odor delay is 1.2s
        % 4-second baseline + 2.44s +2.44s + 8.4s; all bins are aligned to CS1 onset  
        Bins = int64(Session(tr).fv_on_odorcue/BinSize) - 4/BinSize : int64(Session(tr).fv_on_odorcue/BinSize + 13.8/BinSize);
        if numel(Bins) == 180
            Bins(180) = [];
        end
        
        % After pump alignment. Bins3 align to the reailgned reward time
            % 4-second Baseline; 40 bins of .100s
%             Bins1 = int64(Session(tr).fv_on_odorcue/BinSize) - 4/BinSize : int64(Session(tr).fv_on_odorcue/BinSize)-1;
%             % CS1 to CS2-US delay (overlap a bit of US bins for pump1)
%             Bins2 = int64(Session(tr).fv_on_odorcue/BinSize) : int64(Session(tr).fv_on_odorcue/BinSize + 2.444/BinSize + 2.444/BinSize);
%             if numel(Bins2) == 49
%                 Bins2(50) = Bins2(49) +1;
%             end
%             % 1-second before reward, reward, and 8.4s after reward
%             Bins3 = int64(Session(tr).reward_time/BinSize) -1/BinSize : int64(Session(tr).reward_time/BinSize) + 8.4/BinSize;
            
            % TD_19 with jitter
%             % 2-second Baseline; 20 bins of .100s 
%             Bins1 = int64(Session(tr).fv_on_odorcue/BinSize-1) - 2/BinSize :int64(Session(tr).fv_on_odorcue/BinSize-1); Bins1 = Bins1(end-int64(2/BinSize)+1:end);
%             % CS1 plus 1.2 seconds; 24 bins of .100s
%             Bins2 = Bins1(end)+1 : Bins1(end)+1 + 2.4/BinSize; Bins2 = Bins2(1:int64(2.4/BinSize));
%             % 1.2s before CS2; 12 bins of .100s
%             Bins3 = int64(Session(tr).fv_on_rewcue/BinSize-1) - 2/BinSize :int64(Session(tr).fv_on_rewcue/BinSize-1); Bins3 = Bins3(end-int64(1.1/BinSize):end);
%             % CS2, Reward and 8s afrer Reward; 112 bins of .100s
%             Bins4 = Bins3(end)+1 : Bins3(end)+1 + int64(11.2/BinSize); Bins4 = Bins4(1:int64(11.2/BinSize));
            
            if tr == 150 && Bins(end) > length(diam)
               diam((length(diam)+1):Bins(end)) = NaN;
            end
                    
            Matrices.(Regions{teil}).matrix(uu, :, tr) = diam(Bins);
        end
        
        Matrices.(Regions{teil}).mouse(uu, 1) = string(PVsmall.info(u).animal);
        % Create trial matrix;
        TM_ = NaN(1, 3, Trials);
        CS1 = [Session.curr_odorcue_odor_num];
        CS2 = [Session.curr_rewardcue_odor_num];
        US = [Session.drop_or_not];
        if ismember(u,111:330)
            inhibit_or_not = Session.inhibit_or_not;
            TM_(1,4,:)= inhibit_or_not;
        elseif ismember(u,331:430)
            excite_or_not = Session.excite_or_not;
            TM_(1,4,:) = excite_or_not;
        else
            TM_(1,4,:) = nan(size(CS1));
        end
        TM_(1, 1, :) = CS1; TM_(1, 2, :) = CS2; TM_(1, 3, :) = US; 
%         if Trials == 125; TM(1, :, 126:150) = NaN; end
        Matrices.(Regions{teil}).trialMatrix(uu, :, :) = TM_;
        
        
        Namer = cat(1, Namer, Adder);
        Pupil = cat(1, Pupil, Matrices.(Regions{teil}).matrix(uu, :, :));
        TM = cat(1, TM, TM_);
        Pump = cat(1,Pump,pump);
    end
    
    % Change odor identity to the likelihood of the CS1 and CS2 (5 means odor A; 6 means odor B; 7 means odor C; 8 means odor D) 
    Matrices.Pupil.trialMatrix(Matrices.Pupil.trialMatrix==10)=6;
    
    % Matrices.Pupil.trialMatrix(:,:,1:5) = [];
    % Matrices.Pupil.matrix(:,:,1:5) = [];    %Remove the first 5 trials from matrix and trialmatrix to make the baseline for A and B equal
    % Save Before
%     parsave("/zi-flstorage/data/Angela/DATA/TD23/Pupil/Matrices/PMC_ses_" + num2str(s), Matrices);
    s
end
TM(TM==10) = 6;


size(Pupil)
% save("/zi-flstorage/data/Angela/DATA/TD23/Matrices/M_TM_Events_Pupil.mat", "Pupil", "TM", "Events","Namer","Pump")

%% Clean the Pupil
%modified from CleanSession_Loop.m in TD22
% 1st round: load '/zi-flstorage/data/Angela/DATA/TD23/Matrices/M_TM_Events_Pupil.mat'
% 2nd_round: load '/zi-flstorage/data/Angela/DATA/TD23/Matrices/Pupil_pre-clean.mat'

Cleaned = NaN(size(Pupil));
Removed = NaN(size(Pupil));
% for s = 1:size(Pupil,1)
for s = 1:size(Pupil,1)
    [pemp, remp] = CleanPupil_2024(Pupil(s, :, :), TM(s, :, :), int64(Events), 4, 0);
    Cleaned(s, :, :) = pemp;
    Removed(s, :, :) = remp;
%     parsave_img("/zi-flstorage/data/Angela/DATA/TD23/Pupil/plots/remove_artifacts/2nd_Round", "session_" + Namer(s,3) + "_mouse_" + Namer(s,2), 0, 1, 0)
%     sgtitle("Mouse " + Namer(s,2) + ", session " + Namer(s,3));
%     close gcf
%     sgtitle(Namer(s, 2) + " " + Namer(s, 3))
%     pause
    s
end

M = Cleaned; %M is now the pupil matrix after cleaning

save("/zi-flstorage/data/Angela/DATA/TD23/Matrices/Clean_Pupil.mat", "M", "TM", "Events","Namer","Pump")


























