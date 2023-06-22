%% Assign silencing to half of the trials of each trial type
% Ran the Select_Exp_Vec_Max3Reps.m before to generate experiments_max3reps.mat

load '\\zisvfs12\Home\yi.zhuo\Documents\GitHub\TD23\Experiment\Matlab\experiments_max3reps';

for ses = 1:size(experiments_max3reps,3)

    session_trialtypes = experiments_max3reps(:,4,ses);
    
    for tr = 1:8    %there are total of 8 trial types
    trial_idx = find(session_trialtypes == tr);
    total_nr_trialtype = numel(trial_idx);
        if mod(total_nr_trialtype, 2) == 0
%             tagged_trial_OrNot(1:(0.5*total_nr_trialtype),5) = 1;
%             tagged_trial_OrNot((0.5*total_nr_trialtype):total_nr_trialtype,5) = 0;
           tagged_trial_OrNot(1:total_nr_trialtype, 5) = randi([0,1], total_nr_trialtype, 1);

        elseif mod (total_nr_trialtype, 2) == 1
            tagged_trial_OrNot()

        end
    
    end

   

end
