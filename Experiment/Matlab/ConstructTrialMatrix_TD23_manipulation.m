function [trialmatrix] = ConstructTrialMatrix_TD23_manipulation(chapter,ex_vectors_cur)

%% extract parameters of chapter

odorcue_odors = chapter.odorcue_odors(1, :);
rewardcue_odors = chapter.rewardcue_odors(1, :);
num_of_odorcue_odors = length(odorcue_odors);
num_of_rewardcue_odors = length(rewardcue_odors);
odorcue_odor_freq = chapter.odorcue_odor_freq(1, :);
rewardcue_odor_freq = chapter.rewardcue_odor_freq(1, :);
rew_probs = chapter.rew_prob(1, :);
rew_sizes = chapter.rew_sizes(1, :);
%lick_delays = chapter.lick_delay(current_chapter, :);
odorcue_odor_duration = chapter.odorcue_odor_duration(1, :);
rewardcue_odor_duration = chapter.rewardcue_odor_duration(1, :);


%             %modify ex_vectors_cur
%             
%             vec_odorcue_odor=ex_vectors_cur(:,1);
%             vec_odorcue_odor(find(vec_odorcue_odor==1))=odorcue_odors(1);
%             vec_odorcue_odor(find(vec_odorcue_odor==0))=odorcue_odors(2);
%             
%             vec_rewardcue_odor=ex_vectors_cur(:,1);
%             vec_rewardcue_odor(find(vec_rewardcue_odor==1))=rewardcue_odors(1);
%             vec_rewardcue_odor(find(vec_rewardcue_odor==0))=rewardcue_odors(2);
            

%             VOI_odor=vec_odorcue_odor(index,1); 
%             VOI_rew=ex_vectors_cur(index,2);

%             edit fill in final session vector

complete_session_vect = zeros(size(ex_vectors_cur,1),7);
complete_session_vect(:,6)=ex_vectors_cur(:,3); 
complete_session_vect(:,7)=ex_vectors_cur(:,4); 
complete_session_vect(:,8)=ex_vectors_cur(:,5);

%           set odorcue_odor numbers and odor_durations           
       for ix=1:size(ex_vectors_cur,1)
    
        switch(ex_vectors_cur(ix,1))
        
            case 1 
                
                complete_session_vect(ix,2) = odorcue_odor_duration{1,1}; % "{" because cell type
                complete_session_vect(ix,1) = odorcue_odors(1);
                
                
            case 0 
                complete_session_vect(ix,2) = odorcue_odor_duration{1,2};
                complete_session_vect(ix,1) = odorcue_odors(2);
        end
       end
%           set rewardcue_odor numbers, odor_durations and reward sizes
     for ix=1:size(ex_vectors_cur,1)
    
        switch(ex_vectors_cur(ix,2))
        
            case 1 
                complete_session_vect(ix,4) = rewardcue_odor_duration{1,1};                
                complete_session_vect(ix,3) = rewardcue_odors(1);
                if ex_vectors_cur(ix,3) == 1
                    complete_session_vect(ix,5)= rew_sizes{1,1};
                else
                    complete_session_vect(ix,5)= 0;
                end
                    
            case 0                              
                complete_session_vect(ix,4) = rewardcue_odor_duration{1,2};
                complete_session_vect(ix,3) = rewardcue_odors(2);
                if ex_vectors_cur(ix,3) == 1
                    complete_session_vect(ix,5)= rew_sizes{1,2};
                else
                    complete_session_vect(ix,5)= 0;
                end
        end
     end
    
trialmatrix=complete_session_vect;
            
%format to table

trialmatrix=table(trialmatrix(:,1), trialmatrix(:,2), trialmatrix(:,3), trialmatrix(:,4), trialmatrix(:,5), trialmatrix(:,6), trialmatrix(:,7), trialmatrix(:,8), 'VariableNames', {'odorcue_odor_num', 'odorcue_odor_dur', 'rewardcue_odor_num', 'rewardcue_odor_dur', 'rew_size', 'drop_or_not', 'trialtype', 'inhibit_or_not'});

end

function output = lcms(numberArray)

numberArray = reshape(numberArray, 1, []);

%% prime factorization array
for i = 1:size(numberArray,2)
    temp = factor(numberArray(i));
    
    for j = 1:size(temp,2)
        output(i,j) = temp(1,j);
    end
end

%% generate prime number list
p = primes(max(max(output)));
%% prepare list of occurences of each prime number
q = zeros(size(p));

%% generate the list of the maximum occurences of each prime number
for i = 1:size(p,2)
    for j = 1:size(output,1)
        temp = length(find(output(j,:) == p(i)));
        if(temp > q(1,i))
            q(1,i) = temp;
        end
    end
end

%% the algorithm
z = p.^q;

output = 1;

for i = 1:size(z,2)
    output = output*z(1,i);
end
end