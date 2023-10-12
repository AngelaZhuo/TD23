% Modified from RhdToDat_MA and RhdToDat_TD23
% Linus script
% Copy all the protocol files from raw folders to KS3 folders for running DstructKSwrapTD23.m 
clear

Functions_directory = "/home/yi.zhuo/Documents/Github"; addpath(genpath(Functions_directory))
Day_path = '/zi-flstorage/data/Angela/DATA/TD23/RAW';
output_dir = '/zi-flstorage/data/Angela/DATA/TD23/KS3Output/';

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
    I_f=strfind(rhd_path, filesep);         %Index of foldernames '/ or \'
    N_p= rhd_path(I_f(end-2)+1:I_f(end-1)-1);       %Name of Paradigm or Experiment
    
    session_folder = [output_dir, N_p, filesep,rhd_files{1}(1:end-4)];


try
    protocolfile = getAllFiles(rhd_path,'*protocol*',1); % also copy txt file if real protocol not available
    status = copyfile(protocolfile{1,1},session_folder);
catch
    fprintf('Could not copy protocol file');
end
end
end