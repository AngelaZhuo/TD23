%% Experimental vector selection for manipulation sessions
% Same trial type no more than 2 in a row

clear all

load '\\zisvfs12\Home\yi.zhuo\Documents\GitHub\TD23\Experiment\Matlab\experiments';



% find single-session vectors from the "pre-determined experiments
% vectors" (collection of 870 sessions) that have no more than 2 trials of
% the same type consecutively (the original has up to 3 repetitions).


% save vectors with max. 2 in a new variable
experiments_max3reps = [];

for ses = 1:size(experiments,3)
    current_trialtypes = experiments(:,4,ses);

    % ChatGPT: "In Matlab, I have a vector with numbers. How can I find the  maximum number of repetitions of the same number in a row?"
    % Find the differences between consecutive elements
    differences = diff(current_trialtypes);
    
    % Find the indices where the differences are nonzero
    nonzeroIndices = find(differences ~= 0);
    
    % Calculate the maximum number of repetitions
    maxRepetitions = max(diff(nonzeroIndices));
    
    % Display the result
    disp(['Maximum number of repetitions: ', num2str(maxRepetitions)]);
    if maxRepetitions<4
        experiments_max3reps = cat(3,experiments_max3reps,experiments(:,:,ses));
    end
end

save experiments_max3reps.mat experiments_max3reps
