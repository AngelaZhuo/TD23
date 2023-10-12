% Modified from RhdToDat_MA.m and RhdToDigitals.m for the TD23 cohort
%Linux script
clear

Functions_directory = "/home/yi.zhuo/Documents/Github"; addpath(genpath(Functions_directory))
Day_path = '/zi-flstorage/data/Angela/DATA/TD23/RAW';
output_dir = '/zi-flstorage/data/Angela/DATA/TD23/KS3/';
load '/home/yi.zhuo/Documents/Github/TD23/Analysis/ephys_processing/ChannelMapAZ.mat';
map = ChannelMapAZ;

Day_folder_list = dir(Day_path);
pat = {'.','test','template','20230515','freelymoving'};   %remove day folders that do not contain experimental data
Relevant_Days = ~contains({Day_folder_list.name}, pat);
Day_folder_list = Day_folder_list(Relevant_Days);

for dx = 1:numel(Day_folder_list)
Day_folder_path = fullfile(Day_folder_list(dx).folder,Day_folder_list(dx).name);
subject_list = dir(Day_folder_path);

for an = 3:numel(subject_list)

    rhd_path = fullfile(subject_list(an).folder, subject_list(an).name, filesep);
    rhd_files = getAllFiles(rhd_path,'*.rhd',0);
    
    % Bundle sessions
    session_bundle = BundleSession(rhd_files, rhd_path);
 

for session=1:numel(session_bundle)
    
    rhdsortedfiles=session_bundle{session};


    %% create folder for processed data in the format of "animal-ID_animal-ID_mmddyy_time"
    I_f=strfind(rhd_path, filesep);         %Index of foldernames '/ or \'
    N_p= rhd_path(I_f(end-2)+1:I_f(end-1)-1);       %Name of Paradigm or Experiment
    mkdir([output_dir, N_p]);      %Folder for converted Data session-wise
    animal = rhd_path(I_f(end-1)+1:I_f(end)-1);
    session_folder = [output_dir, N_p, filesep,rhdsortedfiles{1}(1:end-4)];
    mkdir(session_folder);
    ident= ([output_dir, N_p,filesep,rhdsortedfiles{1}(1:end-4),filesep,rhdsortedfiles{1}(1:end-4)]);
    
     %% looking for array map (Intan channel order into desired channel order (tetrode groups) N_p= dfldr{end-2}(sstr(1)+1:end)
     
    array_map=map.(animal).array_map;
    
    num_of_ntrodes=size(array_map,2);
    
    %% allocate space on hdd for blockwise writing (because appending in a mat-file is not possible)
    
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
    
    % prep for continous LFP mats ...
    lfpchannels=double(zeros(ceil((session_length/sample_rate)*1000), num_of_ntrodes));
    
    %% Load data from Intan-files blockwise (normally 10-minute files)
    
    for i = 1:numel(rhdsortedfiles)
        
        % load data
        disp('reading...')
        [a_data, d_data, ~, ~, ~, ~, aux_input_data]  = IntanImport(rhdsortedfiles{i}, rhd_path);
        %a_data(amplifier) is the ephys data
        %board_adc_data=(board_adc_data)'; TD23 does not have adc (sniff) data 
        idx=cell2mat(array_map)+1;
        try
            aa_data=a_data(:,idx);            
        catch err
            disp(getReport(err,'extended')); 
            return
        end
        
        if i==1 
            if length(unique(aux_input_data))>1
            aux_given = true;
            subfactor = (sample_rate/100)/4;
            aux = aux_input_data(:, 1:subfactor:end);
            else
                aux_given = false;
%                 error('no aux')
            end
        else
           if aux_given
              aux = [aux aux_input_data(:, 1:subfactor:end)];
           end
        end
        
        % get index
        if i==1
            first_index=1;
            last_index=num_of_samples{1};
            slow_first_sample = 1;
            slow_last_sample = round((num_of_samples{1}/sample_rate)*1000);
        else
            first_index=last_index+1;
            last_index=last_index+num_of_samples{i};
            slow_first_sample = round(slow_last_sample+1);
            slow_last_sample = round(slow_last_sample+(num_of_samples{i}/sample_rate)*1000);
        end
        
    %% write the appropriate channels in the files of individual n-trodes

        disp('writing...')
        
        % write channels to binary .dat file for KS and convert to
        % microvolts 
        startSample = 1;

        stopSample = size(aa_data,1);

        currSamples = double(aa_data(startSample:stopSample,:));
        currSamples = 0.195 * (currSamples - 32768);
        
        % first chunk
        if i==1 %
            
            fidout = fopen([ident '.dat'],'W');
            fwrite(fidout,currSamples','int16');
            fclose(fidout);
            
        % append later chunks
        elseif i==2
            
            fidout = fopen([ident '.dat'],'A');
            fwrite(fidout,currSamples','int16');
        elseif i>2 && i<numel(rhdsortedfiles)
            fwrite(fidout,currSamples','int16');
            
        elseif i==numel(rhdsortedfiles)
            
            fwrite(fidout,currSamples','int16');
            
            fclose(fidout);
            
        end
        
        
        % write digitals
        digital_file.dchannels(first_index:last_index,:)=d_data;
        
        %ntrodes and lfp
        for jj=1:num_of_ntrodes
            temp_lfp = median(a_data(:,array_map{jj}+1),2);
            temp_lfp2 = reshape(temp_lfp, [(sample_rate/1000) size(temp_lfp, 1)/(sample_rate/1000)]);
            temp_lfp2 = squeeze(median(temp_lfp2,1));
            lfpchannels(slow_first_sample:slow_last_sample, jj) = 0.195 * (double(temp_lfp2)' - 32768);
            
        end
        clear temp_lfp temp_lfp2
               
        
        
    end
    %save([ident '_lfp.mat'], 'lfpchannels', '-v7');  Did not process lfp data 
   if aux_given
      save([ident '_aux.mat'], 'aux', '-v7');  
   end
    fclose('all'); %close all files to prevent error when batch-processing a large number of sessions.
    
end   
end
end

