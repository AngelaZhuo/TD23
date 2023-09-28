function kilosort3wrap_TD23(soi)
%modified from kilosort3wrap_TD19
%function rez_post = kilosort3wrap_TD19(data_dir,animal,clst,mapStr)
% list sessions to process, exclude those already processed  if ~recompute
% warning('Only temp file will be created, take out return in l.185 (kilosort3wrap_TD19.m) if you want to run the whole script')

recompute = 0; %1 means overwriting the session that's been processed
clst = [8, 6, 4]; %1st value is ops.Th (1st threshold), 2nd value is 2nd threshold, 3rd value is how many channels KS use to detect spike 
database = '/zi-flstorage/data/Angela/DATA/TD23/KS3';
clstStre = ['thr' num2str(clst(1)) '-' num2str(clst(2)) '_lam20_ch' num2str(clst(3)) '_NT160064'];
mapStr ='';
logDir = [database filesep 'log' filesep];
if ~isfolder(logDir)
    mkdir(logDir)
end

if ~isempty(mapStr)
    warning(['output saved in folder ' mapStr])
else
    warning('Channelmaps with broke channels!')
end
pthPre =getPre(1);pthPre = pthPre{2};

% if ispc
%     pthPre = 'W:\group_entwbio\data\Mirko\';
% elseif isunix
%     pthPre = '/zi-flstorage/data/Mirko/';
% end



if isempty(soi)
    dirlist = dir(database);
    dirlist = dirlist(3:end);
    dirlist = dirlist([dirlist.isdir]);
    dirlist(strcmp({dirlist.name},'log'))=[];
else
    for sx = 1:numel(soi)
        dirlist(sx).folder = database;
        dirlist(sx).name = soi(sx).ID;
    end
end

if ~recompute
    done = false(numel(dirlist),1);
    for ses = 1:numel(dirlist)
        currD = [dirlist(ses).folder filesep dirlist(ses).name];
        subdirlist = dir(currD);
        if any(strcmp([clstStr mapStr],{subdirlist.name}))
            done(ses)=true;
        end
    end
    dirlist(done)=[];
end

[dirlist.done] = deal(false);

% keep looping until all sessions are done -> if not all sessions are
% yet processed function leaves them out coming back later to check if
% they've been processed by then
while ~isempty(dirlist)
    
    %     currfolders = {dirlist.name};
    
    % get folder list with .dat files to run Kilosort
    for dx=1:length(dirlist)
        
        df = getAllFiles([dirlist(dx).folder filesep dirlist(dx).name],'*.dat',0);
        lfpf = getAllFiles([dirlist(dx).folder filesep dirlist(dx).name],'*lfp.mat',0);
        if ~isempty(df) && ~isempty(lfpf)
            dirlist(dx).hasdat = true;
        else
            dirlist(dx).hasdat = false;
        end
        
    end
    
    
    % loop over sessions in a function so that even when a session fails, the rest of
    % the sessions will get processed
    for ses = find([dirlist.hasdat])    %1:numel(dirlist)
        
        if 0
            % choose right map according to cohort, date and box
            fn = dirlist(ses).name;
            prot = cell2mat(getAllFiles([dirlist(ses).folder filesep dirlist(ses).name],'*protocol.mat',0));
            f_ = strfind(fn,'_');
            dateStr = str2double(fn(f_(1)+1:f_(2)-1));
            genotype = fn(2:3);
            box = prot(1);
            
            if strcmp(genotype,'d1')
                if dateStr >= 200121
                    mapStr = '_late';
                elseif dateStr <= 200112 && strcmp(box,'B')
                    mapStr = '_earlyB';
                elseif dateStr <= 200120
                    mapStr = '_early';
                end
            elseif strcmp(genotype,'d2')
                if dateStr >= 200113
                    mapStr = '_late';
                elseif dateStr <= 200112 && strcmp(box,'B')
                    mapStr = '_earlyB';
                elseif dateStr <= 200112 && strcmp(box,'A')
                    mapStr = '_early';
                end
            elseif strcmp(genotype,'da')
                if dateStr >= 200326
                    mapStr = '_late';
                elseif dateStr <= 200325
                    mapStr = '_early';
                end
            end
        end
        
        fprintf('\n processing session# %d in %d \n \n', ses, numel(dirlist))
        try
            ks3session(dirlist,ses,mapStr,clst,pthPre)
            dirlist(ses).done = true;
        catch err
            warningMsg = [datestr(datetime) ': ' dirlist(ses).name ' ' clstStr ' failed!'];
            warning(warningMsg)
            disp(getReport(err,'extended'));
            
            %write error info directly to logfile
            fid = fopen([logDir 'ks3Wrap_faillog ' datestr(date)],'a+');
            fprintf(fid,'%s\n',warningMsg);
            fprintf(fid,'%s\n',err.message);
            for e=1:length(err.stack)
                fprintf(fid,'%s at %i\n',err.stack(e).name,err.stack(e).line);
            end
            fclose(fid);
        end
    end
    %remove sessions already processed from list
    dirlist([dirlist.done]) = [];
    disp('Waiting for sessions to be preprocessed.')
    disp([num2str(numel(dirlist)) ' pending.'])
    pause(120)
end
end

function ks3session(dirlist,ses,mapStr,clst,pthPre)
rootZ = [dirlist(ses).folder filesep dirlist(ses).name];%[data_dir filesep];
rootH = [rootZ filesep 'temp' mapStr];
ffs = strfind(rootZ,filesep); f_ = strfind(rootZ,'_');
animal = rootZ(ffs(end)+1:f_(end-1)-1);
if ~isfolder(rootH)
    mkdir(rootH);
end
pathToChanMap= [pthPre 'GitHub' filesep 'DataProcessing-ephys' filesep 'KS2 batch' filesep 'configFiles_for_KS2'];
pathToYourConfigFile =  [pthPre 'GitHub' filesep 'KS3_Pipeline' filesep 'KilosortConfig']; % take from Github folder and put it somewhere else (together with the master_file)

%%  compute KS chanmap
% conversion from Max used until animal specific channelmaps are
% created
channelmapfile = [pthPre 'GitHub' filesep 'DataProcessing-ephys' filesep 'channel_maps_for_RhdToDat' filesep 'maps.mat'];
maps = load(channelmapfile);
maps = maps.maps;
date = str2double(dirlist(ses).name(end-12:end-7));
time = str2double(dirlist(ses).name(end-5:end));
% mapStrRHD2DAT = getMapstrRHD2DAT(animal,date,[dirlist(ses).folder filesep dirlist(ses).name],time);
chanMap = ChanMapConvert(maps.(animal).array_map,maps.(animal).region,animal);

% for PMC TD19 KS compatible chanMaps are prepared for each animal
%      chanMap = ChanMapConvertTD19(pathToChanMap,[animal mapStr]);





ops.chanMap = chanMap;

ops.NchanTOT  = length(chanMap.chanMap);% total number of channels in your recording

%%

ops.trange    = [0 Inf]; % time range to sort

run(fullfile(pathToYourConfigFile, 'KSconfig.m'))
ops.fproc   = fullfile(rootH, 'temp_wh.dat'); % proc file on a fast SSD

%% params/preproc

ops.fig = false;
fprintf([datestr(datetime) '\n'])
fprintf('Looking for data inside %s \n', rootZ)

% main parameter changes from Kilosort2 to v2.5
ops.sig        = 50;  % spatial smoothness constant for registration
ops.fshigh     = 300; % high-pass more aggresively
ops.nblocks    = 0; % blocks for registration. 0 turns it off, 1 does rigid registration. Replaces "datashift" option.
ops.NChanNear = clst(3);% 8; % try 4 and 16
% main parameter changes from Kilosort2.5 to v3.0
ops.Th       = clst(1:2);%[5 2];
ops.lam = 20;


% find the binary file
fs          = [dir(fullfile(rootZ, '*.bin')) dir(fullfile(rootZ, '*.dat'))];
if length(fs)>1
    fs(ismember('temp_wh.dat', {fs.name})) = [];
end
ops.fbinary = fullfile(rootZ, fs(1).name);


rezraw                = preprocessDataSub(ops);
% return %only to recreate temp files
%% meat+bones
% return;

rez                = datashift2(rezraw, 0);

[rez_spikes, st3, tF]     = extract_spikes(rez);

rez_template                = template_learning(rez_spikes, tF, st3);

[rez_sorted, st3, tF, fW, spikeAmps]     = trackAndSort(rez_template);

rez_clustered               = final_clustering(rez_sorted, tF, st3);

rez_final                = find_merges(rez_clustered, 1);

rez_final = ContaminationPercent(rez_final, 2); % refractory period in ms
%%
[rez_post, spikeAmps_post]  = precuration(rez_final, tF, spikeAmps);
rez_post = find_merges(rez_post,1);
rez_post = reset_clust_ids(rez_post);
rez_post = ContaminationPercent(rez_post, 2); % refractory period in ms
rez_post = RemoveContaminated(rez_post, 20); % throw out if >percent

% rez_duplicates = remove_ks2_duplicate_spikes(rez_post,'overlap_s', 0.0003, 'channel_separation_um', '40');
% rez_duplicates = ContaminationPercent(rez_duplicates, 2); % refractory period in ms

%% export
savedir1 = fullfile(rootZ, ['thr' num2str(ops.Th(1)) '-' num2str(ops.Th(2)) '_lam' num2str(ops.lam) '_ch' num2str(ops.NChanNear) '_NT' num2str(ops.NT) mapStr]);
mkdir(savedir1)
rezToPhy2(rez_final, savedir1);

savedir = fullfile(savedir1, 'precurated');
mkdir(savedir)
rezToPhy2(rez_post, savedir);

%%

rez_post = reset_clust_ids(rez_post);
rez_post = RemoveDoubleDetected(rez_post);
rez_cure = find_more_merges(rez_post,1);
rez_cure = reset_clust_ids(rez_cure);
rez_cure = ContaminationPercent(rez_cure, 1.5); % refractory period in ms

savedir = fullfile(savedir1, 'cured2');
mkdir(savedir)
rezToPhy2(rez_cure, savedir);

%%
rez_dupl = RemoveDoubleDetected(rez_cure);
rez_reconv = RemoveFalsePositive(rez_dupl);

savedir = fullfile(savedir1, 'reconv3');
mkdir(savedir)
rezToPhy2(rez_reconv, savedir);
% keyboard
end

%