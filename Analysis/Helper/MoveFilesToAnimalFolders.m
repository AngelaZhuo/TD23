function MoveFilesToAnimalFolders

clear all

viddir = '\\zistfs02.zi.local\NoSeA\Angela\TD23_videos\20230619';
all_vids = getAllFiles(viddir,'*.wmv',1);
Folder_list = dir(viddir);
Is_Dir = [Folder_list.isdir];
Dir_Name = {Folder_list(Is_Dir).name};   %Get a list of the subdirectories
%Animal_Index = ismember(Dir_Name,{'x01','x02','x03','x04','x05','x06','x07','x08','x09','x10'}); %The index of all the animl folders

for vx = 1:length(all_vids)
    currVidPth =  all_vids{vx};
    I_f = strfind(currVidPth, filesep);
    animal = currVidPth(I_f(end)+1:I_f(end)+3);
    if ismember(animal, Dir_Name)
       Animal_folder_path = fullfile(viddir,animal);
       movefile(currVidPth,Animal_folder_path);
    else
       error('No matching folder for the file')
    end
end