function [chapter, trialmatrix, ex_vectors_cur] = do_constructTrialMatrix_TD23_manipulation(phase)%,JitterButton)
        

        
%         %% get experimental vectors precomputed by JR 
%         %JITTERED
%         if strfind(JitterButton,'JitterOn') == 1 
%         %load('C:\Users\Anwender\Desktop\ExperimentalControl\MRTprediction\experiments_jittered.mat'); % experiments.mat
%         else
        load('D:\TD23\Scripts\Matlab\experiments_manipulation.mat'); % experiments.mat -> max4consec max 4 trialpaths in a row
%         % end
%         %matching with MRI 21thJan 2020
%         ChosenVec = 189;
%         ex_vectors_cur=experiments(:,:,ChosenVec);
       % choose vectors randomly
        random=rand(1);
        if random>0.5
           ChosenVec=ceil(rand(1)*101);
        else
           ChosenVec=floor(rand(1)*101);
        end
        ex_vectors_cur= experiments_manipulation(:,:,ChosenVec);
%        %The experiment.mat contains randomized session information. Each row represents one trial, the first number is the odorcue_odor, the second number
%       is the rewardcue_odor, the third number is the presence of reward and the forth number is the trial type (8 types in total)       

       % get chapter data from GetSessionParameters
       chapter = GetSessionParameters_TD23(phase);
%        chapter.num_of_chapters = size(chapter.rewardcue_odors,1);
       
       
       %% adding Chapter_cur + rewprob_cur to experimental vectors 
       % (4) chapter cur ; (5) reward prob
       
       % Chapter_cur
       %chap_vec= [];
% 
%        if strfind(JitterButton,'JitterOn') == 1 
%            
%           load('C:\Users\Anwender\Desktop\Matlabscripts for TD19\MRTprediction\trials_per_block_jittered_overview');
%           Trials_per_Block_cur= trials_per_block_jittered_overview(:,ChosenVec);
%           
%           for idx=1:length(Trials_per_Block_cur)
%               chap_vec=[chap_vec ones(1,Trials_per_Block_cur(idx))*idx];
%           end
%           
%           % change chapter properties 
%           chapter.blocksizes=Trials_per_Block_cur';
%           chapter.jitter='ON';
%           
%        else
%            
%          Trials_per_Block_cur=[40;40;40];
%           
%          for idx=1:length(Trials_per_Block_cur)
%             chap_vec=[chap_vec ones(1,Trials_per_Block_cur(idx))*idx];
%         end
%          
%         chapter.jitter='OFF';
%          
%        end
%        
%        ex_vectors_cur(:,4)= chap_vec;
       
       %-----
%        % reward prob ??? how to implement paradigm pattern here
%        for idx=1:size(ex_vectors_cur,1)
%            %ProbabilityCode (see Coding above)
%            if ex_vectors_cur(idx,3)==1 || ex_vectors_cur(idx,3)==3
%               ex_vectors_cur(idx,5)=0.80;
%            elseif ex_vectors_cur(idx,3)==2 || ex_vectors_cur(idx,3)==4
%               ex_vectors_cur(idx,5)=0.20; 
%            end
%        end
          
       
       
       %% create trialmatrix 
      
       [trialmatrix] = ConstructTrialMatrix_TD23_manipulation(chapter,ex_vectors_cur);
   

       chapter.NumberExpVectors=ChosenVec;
       chapter.ExpVectors=ex_vectors_cur;
        
           
end