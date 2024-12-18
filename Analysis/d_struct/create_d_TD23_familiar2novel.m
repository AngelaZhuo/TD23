function d = create_d_TD23_familiar2novel(root_dir)
%% This function creates the d-struct for all session folder within the root_dir
% 
%
% by Angela Zhuo 12,2024 adapted from create_d_OFCAI2022_familiar2
% clear;

% these paths might need to be changed
% addpath(genpath('\\zi.local\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Danai\OFC-AI_cohort\scripts\Toolboxes\'));
% root_dir = '\\zi.local\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Danai\OFC-AI_cohort\DATA\PROCESSED\familiar_headfix\';
addpath(genpath('/zi-flstorage/data/Danai/OFC-AI_cohort/scripts/Toolboxes'));
% root_dir = '/zi-flstorage/data/Angela/DATA/TD23/KS3/20230707_social_headfix';
fprintf('Creating d-struct for %s. \n',root_dir);
load(['/zi-flstorage/data/Angela/Scripts/Matlab/ephys_processing' filesep 'ChannelMapAZ.mat']);
maps=ChannelMapAZ;
d = struct;
region_names = {'NAcc' 'OT' 'VTA'};
%% Find all sessions
fprintf('Sanity check of input.\n');
% data_list = getAllFiles(root_dir,'*.dat',1);
data_list_struct = dir([root_dir,filesep,'**',filesep,'*.dat']); % much faster file finding
for ii = 1:numel(data_list_struct)
    data_list{ii,1} = fullfile(data_list_struct(ii).folder, data_list_struct(ii).name);
end

to_remove = [];
% sanitiy check if there is a protocol file for every data-directory
for ii = 1:length(data_list)
    curr_dir = fileparts(data_list{ii,1});
    if length(getAllFiles(curr_dir,'*_protocol.mat',1))~=1
%         warning(['Something is wrong with protocol in ', curr_dir])
%         warning('Session excluded!');
        to_remove = [to_remove, ii];
    end   
end
data_list(to_remove,:) = [];
        
%% Loop over sessions
% fprintf('\n\n');
% fprintf('Looping over sessions\n');
% %Fortschrittsbalken
% fprintf(repmat('|', [length(data_list) 1]))
% fprintf('\n')

% initialize d struct
d.spikes = cell(0,0);
d.map = 1;
d.clust_params = struct;
unit_counter = 1;

to_remove = [];
for ii = 1:length(data_list)
 
    [curr_dir, curr_id] = fileparts(data_list{ii,1});
    cd(curr_dir); 
    protocol_file = dir('*_protocol.mat');
    disp(curr_dir);

    %load protocol-file
    load(fullfile(protocol_file.folder,protocol_file.name),'session');

    %process Protocol file (parse trial-times into trialmatrix from digitals
%     if (~isfield(session.trialmatrix,'fv_on') && ~isfield(session.trialmatrix,'trial_on')) 
    try
       [laser,session,events,warning_msg] = extractDigitalTrialInformation(curr_dir);
    %            load(fullfile(protocol_file.folder,protocol_file.name),'session');
       assert(isfield(session.trialmatrix,'trial_on'))
    catch
       warning(curr_dir);       
       to_remove = [to_remove, ii];
%        continue;
    end
%     end
   
    d.laser{ii} = laser;
    
   %load sniff-file and parse to struct    %No sniff data in TD23 social
%    sniff_file = dir('*_adc.mat');
%    load(fullfile(sniff_file.folder,sniff_file.name),'adcchannels');
%    % downsample to 100 S/s
%    sniff = downsample(adcchannels,300);
%    %%% for P3, also set sniff to resting value of sensor while freely-movin sample phase
%    sniff_zero = sniff;
%    sniff_zero(1:int64((session.trialmatrix(1).trial_on-15)*100)) = median(sniff(1:int64((session.trialmatrix(1).trial_on-15)*100)));
%    d.sniff{ii} = sniff_zero;
   
      
    %parse session-data into d-struct
    d.info(ii).ID = curr_id;
    d.info(ii).name = session.name;
    d.info(ii).time = session.time; %time as matlab timestamp
    d.info(ii).sniff = false; %logical if sniff was recorded in that session, change manually or read from .csv (toDo)
    d.info(ii).array = 'VS_VTA';
    d.info(ii).genotype = 'D1-cre';
    d.info(ii).n_chans = 192;
    d.info(ii).root_file = fullfile(protocol_file.folder,protocol_file.name);
    d.info(ii).root_dir = curr_dir;
    d.info(ii).data_dir = data_list{ii,1};
    d.info(ii).sample_rate = 30000;
    d.info(ii).warning = warning_msg;

    animal = session.name;
      
   %% unit stuff 
    spikes_dir = fullfile(curr_dir,'thr8-6_lam20_ch4_NT160064',filesep,'reconv3',filesep);
    
    %%
%     try
        
    spikes = load_KS_spikes_TD23_social(spikes_dir,d.info(ii).data_dir);
%     spikes = load_KS_spikes(spikes_dir);
    d.spikes = cat(2,d.spikes,spikes.spikes);
    %%
    %%% parse units
    for uc = 1:size(spikes.spikes,2)
        d.clust_params(unit_counter).unit_nr   = unit_counter;
        d.clust_params(unit_counter).session   = curr_id;
        d.clust_params(unit_counter).animal    = session.name;
        d.clust_params(unit_counter).KS_ID     = spikes.clust_params(uc).KS_ID;
        d.clust_params(unit_counter).KS_label  = spikes.clust_params(uc).KS_label;
        %        d.clust_params(unit_counter).chan      = spikes.clust_params(uc).chan;
        d.clust_params(unit_counter).trode     = spikes.clust_params(uc).tetrode;
        tetrode = d.clust_params(unit_counter).trode;
        %            d.clust_params(unit_counter).mean_fr   = spikes.clust_params(uc).mean_fr;
        d.clust_params(unit_counter).mean_fr   =  get_mean_fr_TD23social(spikes.spikes{uc},events);  %Calculate mean_fr from first trial_on to last trial_off, excluded the tagging period
        %            d.clust_params(unit_counter).std_fr    = spikes.clust_params(uc).std_fr;
        d.clust_params(unit_counter).ref_viols = spikes.clust_params(uc).ref_violations;
        d.clust_params(unit_counter).ISI_mean  = spikes.clust_params(uc).ISI_mean;
        d.clust_params(unit_counter).ISI_median= spikes.clust_params(uc).ISI_median;
        d.clust_params(unit_counter).ISI_cv    = spikes.clust_params(uc).ISI_cv;
        d.clust_params(unit_counter).wf        = spikes.clust_params(uc).wf;
        try
            d.clust_params(unit_counter).region_coding = maps.(animal).region(tetrode);%d.clust_params(ux).tetrode);
            d.clust_params(unit_counter).region = region_names{maps.(animal).region(tetrode)};%d.clust_params(ux).tetrode)};
        catch
            d.clust_params(unit_counter).region_coding = 99;
            d.clust_params(unit_counter).region = 'LFPorOFF';
            warning_msg = ['Unit ' num2str(unit_counter) ' on tetrode ' num2str(tetrode) ' detected!'];
            warning(warning_msg);%d.clust_params(ux).tetrode
            d.info(ii).warning = append(d.info(ii).warning,'--',warning_msg);
    %         disp(getReport(MException.last))
        end
        d.clust_params(unit_counter).side = maps.(animal).side(tetrode);
        d.map(unit_counter) = ii;
        unit_counter = unit_counter +1;
    end
%     catch
%         warning(['No spikes: ',curr_dir]);       
%     end
   
   %%% parse trialmatrix
   d.events{ii} = session.trialmatrix;
   
   fprintf('\n \n');

end

fprintf('\n \n');

savedir = '/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/social';

save([savedir,filesep,'d_social_' date '.mat'],'d','-v7.3');
end

function [laser,session,events,warning_msg] = extractDigitalTrialInformation(inputDir)
%% extracts timestamps of trials and parses to protocol file
if nargin == 0
    inputDir = uigetdir;
    inputDir = [inputDir,filesep];
end

%% get all rhds and mats
protocollist=getAllFiles(inputDir, '*protocol.mat', 1);
diglist=getAllFiles(inputDir, '*digital.mat',1);
% if there is no digital file, convert from .rhd
if isempty(diglist) || isempty(protocollist)
    error('Please select a directory that contains the protocol-file and the already converted digital.mat files');
end

load(protocollist{1,1});
load(diglist{1,1});

%% get trialinformation

events = session.trialmatrix;
odor_logical = [events.odor_num]~=0;
events = events(odor_logical);

% tagging(laser) info
laser = find(diff(dchannels(:,1))==1)/sample_rate; %in scec

% trial-onsets
try
    % parse Trial start time
    trial_on=find(diff(dchannels(:,3))==1)/sample_rate;
    trial_off=find(diff(dchannels(:,3))==-1)/sample_rate;
    trial_dur=trial_off-trial_on;
    % remove wrong timepoints
    ToDelete= find( trial_dur > 4 | trial_dur < .2); %only take the odor trials
    trial_on(ToDelete)= [];
    trial_off(ToDelete)= [];
    %sanity checks
    if numel(trial_on) ~= numel(trial_off)
        error('Unequal number of trial on and off');
    elseif numel(trial_on) ~= size(events,2)
        error('Unequal number of trials and trial on');
    end
    % parse event-times info to trialmatrix
    for t = 1:size(events,2)
        session.trialmatrix(t).trial_on = trial_on(t);
        session.trialmatrix(t).trial_off = trial_off(t);
        events(t).trial_on = trial_on(t);
        events(t).trial_off = trial_off(t);  %for mean_fr calculation
    end
catch
   warning('Some problem with trial_onset extraction'); 
end


% if odor cases
if any([session.trialmatrix.odor_num] > 0)
    fv_on=find(diff(dchannels(:,2))==1)/sample_rate;
    fv_off=find(diff(dchannels(:,2))==-1)/sample_rate;
    fv_dur=fv_off-fv_on;
    
    % remove false signals detected..
    % included parts from SessionDfromKS_TD23_social
    try 
        fv_dist = [0;diff(fv_on)]; %inter-trial interval
    catch
        fv_dist = [0 diff(fv_on)];
    end
    ToDelete= find( fv_dur >1.05 | fv_dur < 0.95);
    
    ITI2long=find(fv_dist>20);

    if numel(1:ITI2long-1)<numel(ITI2long:numel(fv_dist))
        ITIdel = 1:ITI2long-1;
    else
        ITIdel = ITI2long:numel(fv_dist);
    end

    try
        ToDelete = [ToDelete;ITIdel];
    catch
        ToDelete = [ToDelete,ITIdel];
    end
    
    warning_msg = ''; %-> collects warning messages about session, put into d.info
    if ToDelete
        warning_msg = append(warning_msg,[num2str(numel(ToDelete)) ' false fvon/off detected']);
    end
    fv_on(ToDelete)= [];
    fv_off(ToDelete)= [];
    fv_dur(ToDelete)= [];
        
    %sanity checks
    if numel(fv_on) ~= numel(fv_off)
        error('Unequal number of final valve on and off');
    elseif numel(fv_on) ~= nnz([session.trialmatrix.odor_num]>0)
        error('Unequal number of final valve and odor-trials');
    end
    
    % parse event-times info to trialmatrix
    for t = 1:nnz([events.odor_num] > 1)
        session.trialmatrix(t).fv_on = fv_on(t);
        session.trialmatrix(t).fv_off = fv_off(t);
    end
    
end

save(protocollist{1,1},'session');


end




