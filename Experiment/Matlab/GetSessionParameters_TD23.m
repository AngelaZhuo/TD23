
function chapter = GetSessionParameters_TD22(scheme)

switch scheme
    
    
   case 'PID5'

        odorcue_odors=[5 5];
        rewardcue_odors=[5 5];

        odor_prob=[0.8 0.2];        
        rew_prob=[0.8 0.2]; 
        chapter.case=scheme;
        
        chapter.max_trials=150;
        chapter.reward_delay=1200;
        chapter.lick_window=7500;
        
        
        chapter.trials_until_end=chapter.max_trials;
        
        
        chapter.odorcue_odors(1,:)=odorcue_odors;
        chapter.rewardcue_odors(1,:)=rewardcue_odors;
        chapter.odorcue_odor_freq(1,:)=[20 20];
        chapter.rewardcue_odor_freq(1,:)=[20 20];
        chapter.rew_prob(1,:)=rew_prob;
        chapter.rew_sizes(1,1:length(chapter.rewardcue_odors(1,:)))={333 333};
        chapter.odorcue_odor_duration(1,1:length(chapter.odorcue_odors(1,:)))={1240 1240};        
        chapter.rewardcue_odor_duration(1,1:length(chapter.rewardcue_odors(1,:)))={1240 1240}; 

    case 'PID6'

        odorcue_odors=[6 6];
        rewardcue_odors=[6 6];

        odor_prob=[0.8 0.2];        
        rew_prob=[0.8 0.2]; 
        chapter.case=scheme;
        
        chapter.max_trials=150;
        chapter.reward_delay=1200;
        chapter.lick_window=7500;
        
        
        chapter.trials_until_end=chapter.max_trials;
        
        
        chapter.odorcue_odors(1,:)=odorcue_odors;
        chapter.rewardcue_odors(1,:)=rewardcue_odors;
        chapter.odorcue_odor_freq(1,:)=[20 20];
        chapter.rewardcue_odor_freq(1,:)=[20 20];
        chapter.rew_prob(1,:)=rew_prob;
        chapter.rew_sizes(1,1:length(chapter.rewardcue_odors(1,:)))={333 333};
        chapter.odorcue_odor_duration(1,1:length(chapter.odorcue_odors(1,:)))={1240 1240};        
        chapter.rewardcue_odor_duration(1,1:length(chapter.rewardcue_odors(1,:)))={1240 1240}; 

   case 'PID7'

        odorcue_odors=[7 7];
        rewardcue_odors=[7 7];

        odor_prob=[0.8 0.2];        
        rew_prob=[0.8 0.2]; 
        chapter.case=scheme;
        
        chapter.max_trials=150;
        chapter.reward_delay=1200;
        chapter.lick_window=7500;
        
        
        chapter.trials_until_end=chapter.max_trials;
        
        
        chapter.odorcue_odors(1,:)=odorcue_odors;
        chapter.rewardcue_odors(1,:)=rewardcue_odors;
        chapter.odorcue_odor_freq(1,:)=[20 20];
        chapter.rewardcue_odor_freq(1,:)=[20 20];
        chapter.rew_prob(1,:)=rew_prob;
        chapter.rew_sizes(1,1:length(chapter.rewardcue_odors(1,:)))={333 333};
        chapter.odorcue_odor_duration(1,1:length(chapter.odorcue_odors(1,:)))={1240 1240};        
        chapter.rewardcue_odor_duration(1,1:length(chapter.rewardcue_odors(1,:)))={1240 1240}; 
 
   case 'PID8'

        odorcue_odors=[8 8];
        rewardcue_odors=[8 8];

        odor_prob=[0.8 0.2];        
        rew_prob=[0.8 0.2]; 
        chapter.case=scheme;
        
        chapter.max_trials=150;
        chapter.reward_delay=1200;
        chapter.lick_window=7500;
        
        
        chapter.trials_until_end=chapter.max_trials;
        
        
        chapter.odorcue_odors(1,:)=odorcue_odors;
        chapter.rewardcue_odors(1,:)=rewardcue_odors;
        chapter.odorcue_odor_freq(1,:)=[20 20];
        chapter.rewardcue_odor_freq(1,:)=[20 20];
        chapter.rew_prob(1,:)=rew_prob;
        chapter.rew_sizes(1,1:length(chapter.rewardcue_odors(1,:)))={333 333};
        chapter.odorcue_odor_duration(1,1:length(chapter.odorcue_odors(1,:)))={1240 1240};        
        chapter.rewardcue_odor_duration(1,1:length(chapter.rewardcue_odors(1,:)))={1240 1240}; 
        
   case  'onlytagging'
      
        odorcue_odors=[5 6];
        rewardcue_odors=[7 8];

        odor_prob=[0.8 0.2];        
        rew_prob=[0.8 0.2]; 
        chapter.case=scheme;
        
        chapter.max_trials=0;
        chapter.reward_delay=1200;
        chapter.lick_window=7500;
        
        
        chapter.trials_until_end=chapter.max_trials;
        
        
        chapter.odorcue_odors(1,:)=odorcue_odors;
        chapter.rewardcue_odors(1,:)=rewardcue_odors;
        chapter.odorcue_odor_freq(1,:)=[20 20];
        chapter.rewardcue_odor_freq(1,:)=[20 20];
        chapter.rew_prob(1,:)=rew_prob;
        chapter.rew_sizes(1,1:length(chapter.rewardcue_odors(1,:)))={333 333};
        chapter.odorcue_odor_duration(1,1:length(chapter.odorcue_odors(1,:)))={1240 1240};        
        chapter.rewardcue_odor_duration(1,1:length(chapter.rewardcue_odors(1,:)))={1240 1240};  

  case 'MRI_TD_19'

        odorcue_odors=[5 6];
        rewardcue_odors=[7 8];

        odor_prob=[0.8 0.2];        
        rew_prob=[0.8 0.2]; 
        chapter.case=scheme;
        
        chapter.max_trials=150;
        chapter.reward_delay=1200;
        chapter.lick_window=7500;
        
        
        chapter.trials_until_end=chapter.max_trials;
        
        
        chapter.odorcue_odors(1,:)=odorcue_odors;
        chapter.rewardcue_odors(1,:)=rewardcue_odors;
        chapter.odorcue_odor_freq(1,:)=[20 20];
        chapter.rewardcue_odor_freq(1,:)=[20 20];
        chapter.rew_prob(1,:)=rew_prob;
        chapter.rew_sizes(1,1:length(chapter.rewardcue_odors(1,:)))={333 333};
        chapter.odorcue_odor_duration(1,1:length(chapter.odorcue_odors(1,:)))={1240 1240};        
        chapter.rewardcue_odor_duration(1,1:length(chapter.rewardcue_odors(1,:)))={1240 1240};  
        
    case '2/3 MRI_TD_19'

        odorcue_odors=[5 6];
        rewardcue_odors=[7 8];

        odor_prob=[0.8 0.2];        
        rew_prob=[0.8 0.2]; 
        chapter.case=scheme;
        
        chapter.max_trials=100;
        chapter.reward_delay=1200;
        chapter.lick_window=7500;
        
        
        chapter.trials_until_end=chapter.max_trials;
        
        
        chapter.odorcue_odors(1,:)=odorcue_odors;
        chapter.rewardcue_odors(1,:)=rewardcue_odors;
        chapter.odorcue_odor_freq(1,:)=[20 20];
        chapter.rewardcue_odor_freq(1,:)=[20 20];
        chapter.rew_prob(1,:)=rew_prob;
        chapter.rew_sizes(1,1:length(chapter.rewardcue_odors(1,:)))={333 333};
        chapter.odorcue_odor_duration(1,1:length(chapter.odorcue_odors(1,:)))={1240 1240};        
        chapter.rewardcue_odor_duration(1,1:length(chapter.rewardcue_odors(1,:)))={1240 1240};  

        
    case '2/3 MRI_TD_19'

        odorcue_odors=[5 6];
        rewardcue_odors=[7 8];

        odor_prob=[0.8 0.2];        
        rew_prob=[0.8 0.2]; 
        chapter.case=scheme;
        
        chapter.max_trials=50;
        chapter.reward_delay=1200;
        chapter.lick_window=7500;
        
        
        chapter.trials_until_end=chapter.max_trials;
        
        
        chapter.odorcue_odors(1,:)=odorcue_odors;
        chapter.rewardcue_odors(1,:)=rewardcue_odors;
        chapter.odorcue_odor_freq(1,:)=[20 20];
        chapter.rewardcue_odor_freq(1,:)=[20 20];
        chapter.rew_prob(1,:)=rew_prob;
        chapter.rew_sizes(1,1:length(chapter.rewardcue_odors(1,:)))={333 333};
        chapter.odorcue_odor_duration(1,1:length(chapter.odorcue_odors(1,:)))={1240 1240};        
        chapter.rewardcue_odor_duration(1,1:length(chapter.rewardcue_odors(1,:)))={1240 1240};  
 

    case 'pressure_calibration'

        odorcue_odors=[5 12];
        rewardcue_odors=[8 9];

        odor_prob=[0.8 0.2];        
        rew_prob=[0.8 0.2]; 
        chapter.case=scheme;
        
        chapter.max_trials=120;
        chapter.reward_delay=1300;
        chapter.lick_window=7500;
        
        
        chapter.trials_until_end=chapter.max_trials;
        
        
        chapter.odorcue_odors(1,:)=odorcue_odors;
        chapter.rewardcue_odors(1,:)=rewardcue_odors;
        chapter.odorcue_odor_freq(1,:)=[20 20];
        chapter.rewardcue_odor_freq(1,:)=[20 20];
        chapter.rew_prob(1,:)=rew_prob;
        chapter.rew_sizes(1,1:length(chapter.rewardcue_odors(1,:)))={333 333};
        chapter.odorcue_odor_duration(1,1:length(chapter.odorcue_odors(1,:)))={5000 5000};        
        chapter.rewardcue_odor_duration(1,1:length(chapter.rewardcue_odors(1,:)))={5000 5000};  
               
        
    case 'TD23_PMC'
        odorcue_odors=[5 10];
        rewardcue_odors=[7 8];

        odor_prob=[0.8 0.2];        
        rew_prob=[0.8 0.2]; 
        chapter.case=scheme;
        
        chapter.max_trials=150;
        chapter.reward_delay=1200;
        chapter.lick_window=7500;
        
        
        chapter.trials_until_end=chapter.max_trials;
        
        
        chapter.odorcue_odors(1,:)=odorcue_odors;
        chapter.rewardcue_odors(1,:)=rewardcue_odors;
        chapter.odorcue_odor_freq(1,:)=[20 20];
        chapter.rewardcue_odor_freq(1,:)=[20 20];
        chapter.rew_prob(1,:)=rew_prob;
        chapter.rew_sizes(1,1:length(chapter.rewardcue_odors(1,:)))={333 333};
        chapter.odorcue_odor_duration(1,1:length(chapter.odorcue_odors(1,:)))={1200 1200};        
        chapter.rewardcue_odor_duration(1,1:length(chapter.rewardcue_odors(1,:)))={1200 1200};  
    
        
end
end