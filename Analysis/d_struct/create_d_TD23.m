%% AZ create basic d_struct (d.info) for TD23
clear all;
%addpath
addpath('\\zisvfs12\Home\yi.zhuo\Documents\GitHub\TD22\Analysis\d_struct\helpers');

%% buttons
%which project?
% MRTPre = 0;
% TD19 =  1;
TD23 = 1;
% all basics
bs = 1;
% ncounter
nc = 1;
% videopaths
vp = 1;

%% paths %%
% in rawdir all sessions are stored as YYYYMMDD_tag\animalID(s) 
% with rhd-files and protocols
    % rawdir = '\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Mirko\MRTprediction-project\DATA\RAW'; 
    rawdir = '\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD23\RAW';
%d_struct directory
    % savedir = '\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Mirko\MRTprediction-project\DATA\D'; 
    savedir = '\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD23\D-struct';
% video directory
    viddir = '\\zistfs02.zi.local\NoSeA\Angela\TD23_videos';

%% load all sessions with only basic information: paradigm,
%date, time, n-count for paradigm,animal
if bs

session_folders = dir(rawdir);

if TD23    
% all_sessions_txt = getAllFiles(rawdir,'*td*.txt',1);
% all_sessions = [getAllFiles(rawdir,'*protocol.mat',1); all_sessions_txt];
% else
all_sessions = getAllFiles(rawdir,'*protocol.mat',1);
all_sessions = all_sessions(~contains(all_sessions,'test'));
end
all_sessions = sort(all_sessions);

%recording idx
rec_idx = 1;

for sesh_idx = 1:numel(all_sessions)
    
    [path,protocolname,ext] = fileparts(all_sessions{sesh_idx});
    find_= strfind(protocolname,'_');
    find_filesep= strfind(path,filesep);

%no of animals in recording 
findPlus = strfind(path,'+'); %Mirko's protocol script was saved once for 2 animals separated by "+"
noa = 1 + numel(findPlus);

for an_idx = 1:noa
% tag specifying paradigm     
   tag = path(find_filesep(end-1)+10:find_filesep(end)-1);
%    if isequal(tag(end),'2')
%      d.info(rec_idx).tag = tag(1:end-2); 
%      d.info(rec_idx).data_missing = 0;
%    elseif isequal(tag(end-3:end),'cave')
%        d.info(rec_idx).tag = tag(1:end-5);
%        d.info(rec_idx).data_missing = 1;
%    else
   d.info(rec_idx).tag = tag; 
   d.info(rec_idx).data_missing = 0;
%    end
   
% % double session? only for MRTPre
% %if MRTPre
% if noa == 2
% d.info(rec_idx).double = 1;
% else
% d.info(rec_idx).double = 0;
% end
% %end

% animal ### down from here ###
if noa == 1
   d.info(rec_idx).animal =  path(find_filesep(end)+1:end);
elseif noa ==2
   if an_idx == 1
       d.info(rec_idx).animal =  path(find_filesep(end)+1:findPlus-1);    
   else
       d.info(rec_idx).animal =  path(findPlus+1:end);    
   end
end
% box   
if TD23
if sum(find_) ~= 0 
    if contains(protocolname,'A')
    d.info(rec_idx).box =  'A';
    elseif contains(protocolname,'B')
    d.info(rec_idx).box =  'B';
    end
% else
%    d.info(rec_idx).box = 'A';
end
end
% date
   d.info(rec_idx).date = path(find_filesep(end-1)+1:find_filesep(end-1)+8);
% time
if (isequal(ext,'.mat')||strfind(path,'EPhys')~= 0)
   d.info(rec_idx).time = protocolname(find_(end-1)+1:find_(end)-1);
% else
%    rhd_list = getAllFiles(path,'*.rhd',1);
%    [path,filename] = fileparts(rhd_list{1});
%    find_rhd = strfind(filename,'_'); 
%    d.info(rec_idx).time = filename(find_rhd(3)+1:end-2);
end

if TD23
% n_count for basic TD19 paradigm
   d.info(rec_idx).tag_ncount =  []; %tag_ncount gives the info of how many trials a mouse has experienced since the beginning. Use the tag_ncount x 150 to yield trial numbers.
end

% d.info(rec_idx).protocolname = protocolname;

% path for .rhd
   d.info(rec_idx).rhd_path =  path;
   
% add some more fields to info
% d.info(rec_idx).pupil = 0; 
% d.info(rec_idx).single_unit = 0; 
% d.info(rec_idx).LFP = 0;
% if TD22
% d.info(rec_idx).lick = 0; % has to entered manually, see add_lick_logical.m
% elseif MRTPre
% d.info(rec_idx).lick = 1;    
% end
 
   rec_idx = rec_idx +1;
end
end
cd(savedir);
save d.mat d;
end

cd(savedir);
load d;
%% add n-counter for basic TD23 paradigm animal wise
if nc
    
animals = unique({d.info.animal});
paras = unique({d.info.tag});
pat = ["silence", "excite", "PMC"];
base_para = paras(contains(paras,pat));
for a=1:numel(animals)
    n_count = 0;
    % base paradigm
    base_sessions = find(contains({d.info.tag}, base_para) & contains({d.info.animal}, animals(a)));
    for rec_idx = base_sessions
%        if ~isequal({d.info(rec_idx).tag},base_para(3))
%        blocks = find(contains(base_para,d.info(rec_idx).tag));
%        n_count = n_count + blocks/3; 
%        else
%            n_count = n_count + 1;
%        end
       n_count = n_count +1; 
       d.info(rec_idx).tag_ncount = n_count;
    end
    % all other paradigms, no n-count needed
    other_sessions = find(~contains({d.info.tag}, base_para)& contains({d.info.animal}, animals(a)));
    for rec_idx = other_sessions
    d.info(rec_idx).tag_ncount = 0;
    end
end
cd(savedir);
save d.mat d;
end

%% add videopaths

if vp
    clear path
   all_vids = getAllFiles(viddir,'*.wmv',1);
   for vidx =1:numel(all_vids)
   [path{vidx}] = fileparts(all_vids{vidx});

   end
   
%looked for folders with more than one video -> DONE, tidied up
mv_idx =1;
for vidx =1:numel(all_vids)
   [path{vidx}] = fileparts(all_vids{vidx});
    if numel(find(contains(all_vids,path{vidx}))) > 1
    multivid(mv_idx) = vidx;
    mv_idx = mv_idx + 1;
    end
end
mv_paths = (unique(path(multivid)))';

% add vidPaths to d
%ucm = 1; %unclear match: one video match to multiple sessions
for vidx = 1:numel(path) %no_clear_match
    curr_path = path{vidx};
    find_=strfind(curr_path,'-');
    find_filesep = strfind(curr_path,filesep);

    tag = curr_path(find_filesep(end-1)+10:find_filesep(end)-1);
    animal = curr_path(find_filesep(end)+1:end);
    date = curr_path(find_filesep(end-1)+1:find_filesep(end-1)+8);
    
% % in case of 2 sessions in one day
% if tag(end-1:end) == '_2'
%     tag = tag(1:end-2);
%     scnd = 1;
%     cave = 0; 
% elseif tag(end-4:end) == '_cave'
%     tag = tag(1:end-5);
%     cave = 1;
%     scnd = 0;   
% else
%     cave=0; scnd=0;
% end
   
       find(contains({d.info.tag},tag));
        pair_idx = ans;

       find(contains({d.info.animal},animal));
        pair_idx = pair_idx(ismember(pair_idx,ans));

       find(contains({d.info.date},date));
        pair_idx = pair_idx(ismember(pair_idx,ans));        
% if scnd
%     pair_idx = pair_idx(2);
% elseif cave
%     cave_seshs = {d.info(pair_idx).data_missing};
%     pair_idx = pair_idx(find(cell2mat(cave_seshs)));
% end


    if numel(pair_idx) > 1
        d.info(pair_idx(1)).vid_path = curr_path;
%         unclear_match(ucm) = vidx; %-> videos from days where something went wrong or recording was repeated, videos without any note always were the first in the list
%         ucm = ucm+1;
    elseif numel(pair_idx) == 1
        d.info(pair_idx).vid_path = curr_path;
    end
    
end
   
end

cd(savedir);
save d.mat d;
