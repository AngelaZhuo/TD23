

TM = squeeze(experiments_max3reps(:, 4, :))';
Inh = NaN(size(TM));
Types = 1:8;
Maxiter = 100000;
Maxer = NaN(size(TM,1),1);

%%% Change here the maximum number of consecutive inhibited trials
%%% independent of trial type by choosing parameter Consecutive.
Consecutive = 3;
%%%

n = 0;
for s = 1:size(TM,1) % For every different Trial Matrix of 150 trials
    T = TM(s, :); % Put that Trial Matrix into T
    for it = 1:Maxiter % Try up to Maxiter times to find a suitable order of trials to be inhibited FOR THAT WHOLE TRIAL MATRIX
        Iner = zeros(size(T)); 
        Iterate_4 = 0;
        for ty = 1:8 % For each trial type find which will be inhibted
            Undoable = 0;
            for ti = 1:Maxiter % Try up to Maxiter times to find a suitable order of trials to be inhibited FOR THAT TRIAL TYPE 
                Iterate_3 = 0;
                These = find(T==ty);
                Array = zeros(1, numel(T==ty));
                These = These(randperm(numel(These)));

                %%% If you want to inibit 1/3 instead of 2/3 of the rare,
                %%% select this option: 
%                 These = These(1:ceil(numel(These)/2));
                %%% But if you want 2/3, do this:
                These = These(1:ceil(numel(These)/2));
                %%%

                Array(These) = 1;
                for part = 1:numel(Array)-2  % This for loop detects if there are three in a row FOR THAT TRIAL TYPE 
                    if sum(Array(part:part+2)) == 3
                        Iterate_3 = 1;
                        break
                    end
                end
                if Iterate_3 == 0
                    Iner(These) = 1;
                    break
                else % If for that rial type you didn't find a proper order, then pass to the next Trial Matrix
                    Undoable = 1;
                end
            end
            if Undoable == 1
                break
            end
        end
        if Undoable == 1
            continue
        end
        for part = 1:numel(Iner)-Consecutive % This for loop detects if there are four in a row INDEPENDENT OF TRIAL TYPE
            if sum(Iner(part:part+3)) == Consecutive +1
                Iterate_4 = 1;
                break
            end
        end
        if Iterate_4 == 0
            break
        end
    end
    if Iterate_4 == 0
        Inh(s, :) = Iner;
        n = n+1
    end
    Maxer(s) = it;
    s
end

figure
histogram(Maxer, 329) % Just for curiosity how many iterations it took the algorithm to find the solution
figure
imagesc(Inh)

%%%%%%%%%%%%%%%%%%%%
experiments_manipulation = experiments_max3reps;
experiments_manipulation(:, 5, :) = permute(Inh, [2, 3, 1]); % Add the fifth column to the experiments_max3reps. This fifth column indicates the trial to be inhibited.
%%%%%%%%%%%%%%%%%%%%


%% Reality check
Sessions = size(experiments_manipulation, 3);
for s = 1:Sessions
    TM = experiments_manipulation(:, :, s);

    % Do I have max 3 in a row?
    for tr = 1:size(TM,1) - 3
        Inhibited = sum(TM(tr:tr+3, 5));
        if Inhibited == 4; error("There are 4 consecutive inhibited trials in session " + s); end
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
    "Session " + s + " is correct :)" 
end


save("\\zisvfs12\Home\Yi.Zhuo\Documents\GitHub\TD23\Experiment\Matlab\experiments_manipulation.mat", "experiments_manipulation")



























