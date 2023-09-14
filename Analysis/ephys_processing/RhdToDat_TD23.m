% Modified from RhdToDat.m and RhdToDigitals.m for the TD23 cohort

clear

Functions_directory = "\\zisvfs12\Home\yi.zhuo\Documents\GitHub"; addpath(genpath(Functions_directory))
session_path = '\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD23\RAW\20230614_PMC';
maps = 
output_dir = '\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD23\KS3\';

subject_list = dir(session_path);

for an = 3:numel(subject_list)

    rhd_path = fullfile(subject_list(an).folder, subject_list(an).name, filesep);
    rhd_files = getAllFiles(rhd_path,'*.rhd',0);
    
    % Bundle sessions
    session_bundle = BundleSession(rhd_files, rhd_path);
 

for session=1:numel(session_bundle)
    
    rhdsortedfiles=session_bundle{session};


    %% create folder for processed data in the format of "animal-ID_animal-ID_mmddyy_time"
    I_f=findstr(rhd_path, filesep);         %Index of foldernames '/ or \'
    N_p= rhd_path(I_f(end-2)+1:I_f(end-1)-1);       %Name of Paradigm or Experiment
    mkdir([output_dir, N_p]);      %Folder for converted Data session-wise
    animal = rhd_path(I_f(end-1)+1:I_f(end)-1);
    session_folder = [output_dir, N_p,'\',rhdsortedfiles{1}(1:end-4)];
    mkdir(session_folder);
    ident= ([output_dir, N_p,'\',rhdsortedfiles{1}(1:end-4),'\',rhdsortedfiles{1}(1:end-4)]);
    
    
    [~,sample_rate,~,~,~]=LengthRhd(rhd_path, rhdsortedfiles{1});
    
     % Getting session length
    session_length=0;
    for ii=1:numel(rhdsortedfiles)
        [num_of_samples{ii}, ~, ~, num_amplifier_channels{ii}, ~]=LengthRhd(rhd_path, rhdsortedfiles{ii});
        session_length=session_length+num_of_samples{ii};
    end
    
    % Creating space for digital-input data
    [~,~,num_of_digital_inputs,~,~]=LengthRhd(rhd_path, rhdsortedfiles{1});
    dchannels=zeros(session_length, num_of_digital_inputs);
    save([ident '_digital.mat'], 'dchannels', '-v7.3');
    save([ident '_digital.mat'], 'sample_rate', '-append');
    digital_file=matfile([ident '_digital.mat'], 'Writable', true);
    
    clear  dchannels
    
    %% Load data from Intan-files blockwise (normally 15-minute files)
    
    for i = 1:numel(rhdsortedfiles)
        
        % load data
        disp('reading...')
        [~, d_data, ~] = IntanImport(rhdsortedfiles{i}, rhd_path);

        % get index
        if i==1
            first_index=1;
            last_index=num_of_samples{1};
        else
            first_index=last_index+1;
            last_index=last_index+num_of_samples{i};
        end
        
        % write digitals 
        digital_file.dchannels(first_index:last_index,:)=d_data;


               
        
        toc
    end
    fclose('all'); %close all files to prevent error when batch-processing a large number of sessions.
    
end   
end