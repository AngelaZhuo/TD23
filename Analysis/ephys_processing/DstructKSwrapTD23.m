function alldone = DstructKSwrapTD23
%% #######################
% put session selection on d_struct_master script level
% Modified from DstructKSwrapTD19
%%###############
%% parameters
clear
recompute = false; % overwrite already converted sessions
pthPre='/zi-flstorage/data/Angela/DATA/TD23'; %path where the data is stored
clst = [8, 6, 4]; %1st value is ops.Th (1st threshold), 2nd value is 2nd threshold, 3rd value is how many channels KS use to detect spike 
clustering = ['thr' num2str(clst(1)) '-' num2str(clst(2)) '_lam20_ch' num2str(clst(3)) '_NT160064'];
soi = [];

% linux or Windows
% if cwp == 1
% pthPre = 'W:\group_entwbio\data\Mirko\';
% elseif cwp == 3
% pthPre = '/zi-flstorage/data/Mirko/';
% else
%     error('Select current working place (cwp)');
% end
% if ~isempty(fnDappend)
%     clustering = [clustering filesep fnDappend];%cured2';
% else
%     clustering = [clustering filesep 'reconv3'];%cured2';
% end
% fs_cl = strfind(clustering,filesep);
database = [pthPre filesep 'KS3Output' filesep '20230626_PMC_tagging'];
% database = [pthPre{1} 'TD19' filesep 'DATA' filesep 'DONE_KS3_auto'];%/zi-flstorage/data/Max/H18datadata';
% database = '\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Max\H18datadata';
% prdgm = 'TD19_EPhys';
output = [pthPre filesep 'KS3Dstructs' filesep clustering];%/zi-flstorage/data/Max/H18Dstructs';
% database = [database filesep prdgm];
maps = load(['/home/yi.zhuo/Documents/Github/TD23/Analysis/ephys_processing' filesep 'ChannelMapAZ.mat']);
% maps=maps.maps;


%% Get list of all sessions
alldone = false;
cd(database)

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

while ~isempty(dirlist)
% while ~isempty(dirlist) % ugly bug fix to prevent l.73ff to go out of function
currfolders = {dirlist.name};

% get folder list with KS output to put into d-struct
sx = 1;
clear all_sessions KS_sessions sessionID KS_folders

for dx=1:length(currfolders)

    cf = currfolders{dx};
    cf_= strfind(cf,'_');
    all_sessions(dx).animal = cf(1:cf_(1)-1);
    all_sessions(dx).date = num2str(cf(cf_(1)+1:cf_(2)-1)); %str2num(currfolders{dx}(5:10));
    all_sessions(dx).folder = [dirlist(dx).folder filesep dirlist(dx).name];
    
    % KS output present?
    if isfolder([database  filesep currfolders{dx} filesep clustering])
        KS_sessions(sx) = all_sessions(dx);
        sessionID{sx} = currfolders{dx};
        KS_folders{sx} = currfolders{dx};
        sx=sx+1;
    end
    
end
if ~exist('KS_folders','var')
    disp('Waiting for KS output to process')
    pause(1200)
    continue % goes out of while loop in upper while loop, which makes it return to current while loop
end
%% filter sessions
if ~recompute 
  dones = dir(output);
  dones = {dones(3:end).name};
  dones = cellfun(@(x) x(1:end-4), dones, 'UniformOutput', false);
  old_sessions = ismember(KS_folders, dones);%contains(KS_folders, dones);
  old_sessions_all = ismember(currfolders,dones);%contains(currfolders,dones);
  
  KS_sessions(old_sessions) = [];
  sessionID(old_sessions) = [];
  dirlist(old_sessions_all) = [];
end

% list with all pending sessions, those not processed as well
[dirlist.done] = deal(false);

%% convert sessions to .dat, subfolder-structure animal based.
ll = tic;
N_f=length(KS_sessions);
fail_counter = 1;
sc = 1;
pc = 1;

logDir = [database filesep 'log' filesep];
if ~isfolder(logDir)
    mkdir(logDir)
end 


% for k=1:2
for k=1:N_f

    sesTic=tic;
    fprintf('\n processing session# %d of %d \n \n', k, N_f)
    try
        d = SessionDfromKS_TD23(KS_sessions(k).folder, clustering,maps);
        if ~isfolder([output filesep sessionID{k} filesep])
            mkdir([output filesep]);
        end
        save([output filesep sessionID{k}], 'd')
        manageSuccess(KS_sessions,clustering,k,logDir)
    catch err
        d=nan;
        manageFailure(KS_sessions,clustering,k,err,logDir)
        fail_counter = fail_counter+1;
    end   
    
    dirlist(strcmp({dirlist.name},sessionID{k})).done = true;
    clear d
    elapsedTime = floor(toc(sesTic)/60);
    disp(['Processing took ' num2str(elapsedTime) ' minutes']) 
end

dirlist([dirlist.done])=[];

fprintf('Total time was: %d \n', toc(ll));
fprintf('Number of failed Conversions: %d \n', fail_counter-1);
% end
end
end

%% subfunctions

function manageFailure(KS_sessions,clustering,k,err,logDir)

warningMsg = [datestr(datetime) ': ' KS_sessions(k).folder ' ' clustering 'Failed!'];
warning(warningMsg)
disp(getReport(err,'extended'));


%write error info directly to logfile
fid = fopen([logDir 'dstruct direct faillog ' datestr(date)],'a+');
fprintf(fid,'%s\n',warningMsg);
fprintf(fid,'%s\n',err.message);
for e=1:length(err.stack)
    fprintf(fid,'%s at %i\n',err.stack(e).name,err.stack(e).line);
end
fclose(fid);

%         currFail = KS_sessions(k);
%         currFail.reason{1} = err.message;
%
%         for errSt =1:numel(err.stack)
%             currFail.reason{errSt+1} = [err.stack(errSt).name ' ' num2str(err.stack(errSt).line)];
%         end
%
%         failures(fail_counter) = currFail;
%         fail_counter = fail_counter + 1;

end

function manageSuccess(KS_sessions,clustering,k,logDir)
succMsg = [datestr(datetime) ': ' KS_sessions(k).folder ' ' clustering 'succesfully processed!'];

% document success
disp(succMsg)
fid = fopen([logDir 'dstruct_success-log ' datestr(date)],'a+');
fprintf(fid,'%s\n',succMsg);
fclose(fid);
% successes(sc) = KS_sessions(k);
% sc=sc+1;
end