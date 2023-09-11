function MoveFilesToAnimalFolders

%Did not use this script at the end as the action only needed to be done once and it is risky to directly alter the raw data 
%first use vidPthRemoveSpace.m to remove all the space in the video names

clear all

viddir = '\\zistfs02.zi.local\NoSeA\Angela\TD23_videos';

all_vids = getAllFiles(viddir,'*.wmv',1);
Date_Folder_list = dir(viddir);
Is_Dir = [Date_Folder_list.isdir];
Date_folder_name = {Date_Folder_list(Is_Dir).name};   %Get a list of the subdirectories
validIndex_logical = ~ismember(Date_folder_name, {'.','..'});
validIndex = find(validIndex_logical);
for vix = 1:numel(validIndex)
    Date_folder_path{vix} = fullfile(viddir, Date_folder_name{validIndex(vix)});
end
%Animal_Index = ismember(Dir_Name,{'x01','x02','x03','x04','x05','x06','x07','x08','x09','x10'}); %The index of all the animl folders

for vx = 1:length(all_vids)
    currVidPth =  all_vids{vx};
    I_f = strfind(currVidPth, filesep);
    animal = currVidPth(I_f(end)+1:I_f(end)+3);
    date = currVidPth(I_f(end)+5:I_f(end)+12);
    Animal_folder_path = fullfile(viddir,date,animal);
    if isfolder(Animal_folder_path) == 1
       movefile(currVidPth,Animal_folder_path);
    elseif
       isfolder(Animal_folder_path) == 0
       mkdir([viddir,date,animal]);
       movefile(currVidPth,Animal_folder_path);
    end
end
