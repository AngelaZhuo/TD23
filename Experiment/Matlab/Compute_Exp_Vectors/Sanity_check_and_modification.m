%sanity check for experimental vectors for manipulation (made by Eleanora), code modified from Create_Exp_Vec_manipulation_WR.mat 
%After the sanity check, modify CS1 to 1 for odor A, 0 for odor B, and 1 for odor C and 0 for odor D, and the array is saved as experiments_manipulation.mat 

load \\zisvfs12\Home\yi.zhuo\Documents\GitHub\TD23\Experiment\Matlab\Compute_Exp_Vectors\experiments_manipulation_30_06_23.mat

%% Sanity check

Sessions = size(experiments_manipulation, 3);
for s = 1:Sessions
    TM = experiments_manipulation(:, :, s);

    % Do I have max 3 in a row of any trialtype in a row?
    for tr = 1:size(TM,1) - 3
        Inhibited = sum(TM(tr:tr+3, 5));
        if Inhibited == 4; error("There are 4 consecutive inhibited trials in session " + s); end
    end
    
    %Do I have max 3 trials of the same trial type silenced in a row (even when interspersed with other trial types)?
    for ty = 1:8
        idx_Inhibited = find(TM(:,4)==ty);
        for iin = 1:(numel(idx_Inhibited)-3) % WAS WRONG
            Inhibited = sum (TM(idx_Inhibited(iin:iin+3),5)); % WAS WRONG
            if Inhibited == 4; error("There are 4 consecutive inhibited trials of the same trial type in session " + s); end
        end
    end

    %Do I have max 4 trials with the same stimulus silenced in a row (even when interspersed with other trial types)?
    for CS1 = 5:6
        idx_Inhibited_CS1 = find(TM(:,1)==CS1);
        for ii1 = 1:(numel(idx_Inhibited_CS1)-4) % WAS WRONG
            Inhibited = sum (TM(idx_Inhibited_CS1(ii1:ii1+4),5)); % WAS WRONG
            if Inhibited == 5; error("There are 5 consecutive inhibited trials with the same CS1 in session " + s); end
        end
    end

    for CS2 = 7:8
        idx_Inhibited_CS2 = find(TM(:,2)==CS2);
        for ii2 = 1:(numel(idx_Inhibited_CS2)-4) % WAS WRONG
            Inhibited = sum (TM(idx_Inhibited_CS2(ii2:ii2+4),5));% WAS WRONG
            if Inhibited == 5; error("There are 5 consecutive inhibited trials with the same CS2 in session " + s); end
        end
    end

    for US = 0:1
        idx_Inhibited_US = find(TM(:,3)==US);
        for ii3 = 1:(numel(idx_Inhibited_US)-4) % WAS WRONG
            Inhibited = sum (TM(idx_Inhibited_US(ii3:ii3+4),5));% WAS WRONG
            if Inhibited == 5; error("There are 5 consecutive inhibited trials with the same US in session " + s); end
        end
    end

    % Am I inhibiting half of each trial type? (If you changed to 1/3 around line 28, then
    % correct also here).
    for ty = 1:8
        Inhibited = sum(TM(TM(:,4)==ty,5));
        TrialType = sum(TM(:, 4) == ty);
            
        %%% If you do 2/3
        if Inhibited ~= ceil(TrialType/2)
            error("You are not inhibiting the right amount of trial type " + ty + " in session " + s)
        end
        %%% Or else if you do 1/3
%         if Inhibited ~= floor(TrialType/2)
%             error("You are not inhibiting the right amount of trial type " + ty + " in session " + s)
%         end
    end
    disp(['Session ' num2str(s) ' is correct']); 
end


%% Modify experimental vectors for experiments

experiments_manipulation(:, 1, :) = (experiments_manipulation(:, 1, :) == 5);
experiments_manipulation(:, 2, :) = (experiments_manipulation(:, 2, :) == 7);

save("\\zisvfs12\Home\Yi.Zhuo\Documents\GitHub\TD23\Experiment\Matlab\experiments_manipulation.mat", "experiments_manipulation")

