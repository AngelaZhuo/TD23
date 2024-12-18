function session_d = load_KS_spikes_TD23_social(myKsDir,data_dir)
%% Loads output from KS2/phy easily and returns spiketimes in seconds, some parameters and mean/median waveforms for each cluster
%
%   Input:
%       myKsDir: Directory containing all files from KS-sorting and
%       Phy2-curation
%
%   Output:
%       session_d: struct in the same format as the bigger d-struct, with
%       spikes + waveforms and their metrics
%
%   Dependencies:
%       - Nick Steinmetz Toolbox: https://github.com/cortex-lab/spikes
%       - EPhys Repo of Kelsch Lab: https://github.com/KelschLAB/ePhys
%
% David Wolf, 2022
% Modified to fit TD23 social experiments, 2024
%% Load myKSdir using Nick Steinmetz toolbox ('spikes')

%%% load structure with almost all necessary information. 
sp = loadKSdir(myKsDir);

%%% parse to cell-array with one cell per cluster
spxtimes = cell(1,numel(sp.cgs));
for ii = 1:size(spxtimes,2)
    spxtimes{1,ii}  = sp.st(sp.clu == sp.cids(ii))';
end
session_d.spikes = spxtimes;

% templatesPositionsAmplitudes - compute some useful things about your spikes and their waveform shapes, like the position along the probe and the amplitudes
[~, ~, templateYpos, ~, tempsUnW, ~, ~] = ...
    templatePositionsAmplitudes(sp(1).temps, sp(1).winv, sp(1).ycoords, sp(1).spikeTemplates, sp(1).tempScalingAmps);


%[~,max_site] = max(max(abs(temps),[],2),[],3); % the maximal site for each template
% one could potentially use the unwhitened templates, but that shouldn't really change the results
[~,max_site] = max(max(abs(tempsUnW),[],2),[],3); % the maximal site for each template
spikeSites = max_site(sp(1).spikeTemplates+1);

spikeSites = uint16(spikeSites);

%%% extract some information like tetrode position etc
for un = 1:numel(spxtimes)
    session_d.clust_params(un).KS_ID        = sp.cids(un); % get KS unit ID
    session_d.clust_params(un).KS_label     = sp.cgs(un); % get KS label (2 = good,1 = mua)
    session_d.clust_params(un).chan         = min(unique(spikeSites([sp.clu]==sp.cids(un))));    % get channel with biggest waveform

    % find tetrode number of unit
    current_template = unique(sp.spikeTemplates(sp.clu==sp.cids(un)))+1; % templates 0-indexed
%     assert(numel(current_template)==1);
    session_d.clust_params(un).tetrode = round(floor(templateYpos(current_template(1))/200));
    
    % mean fr and std of FR
    session_d.clust_params(un).mean_fr = [];
    %[session_d.clust_params(un).mean_fr,session_d.clust_params(un).std_fr]  = get_mean_fr(spxtimes{1,un});
    
    % refractory period violations
    session_d.clust_params(un).ref_violations = get_ref_violations(spxtimes{1,un});
    
    % Inter-spike-interval mean and median and coefficient of variation of
    % ISI
    [session_d.clust_params(un).ISI_mean, session_d.clust_params(un).ISI_median, session_d.clust_params(un).ISI_cv] = ...
        get_isi_metrics(spxtimes{1,un});
end


%% Get wave-forms from raw data: keep 2000 random samples and mean + median waveform
clear gwfparams;
gwfparams.cids = sp.cids;
gwfparams.cgs = sp.cgs;

% spaghetti fixing
[a,b] = fileparts(data_dir); % for OFC-AI cohort
gwfparams.dataDir = a;    % KiloSort/Phy output folder
% gwfparams.fileName = [b,'.dat'];       
gwfparams.fileName = sp.dat_path;   % .dat file containing the raw
gwfparams.curationDir = myKsDir;

gwfparams.dataType = sp.dtype;        % Data type of .dat file (this should be BP filtered)
gwfparams.nCh = sp.n_channels_dat;                     % Number of channels that were streamed to disk in .dat file
gwfparams.wfWin = [-40 41];              % Number of samples before and after spiketime to include in waveform
gwfparams.nWf = 2000;                    % Number of waveforms per unit to pull out
%     t = samples/Fs;         % Time Vector (seconds)  ->  samples = t * Fs
%     (Spike times are in seconds)
gwfparams.spikeTimes = sp.st.*30000; % Vector of cluster spike times (in samples) same length as .spikeClusters
gwfparams.spikeClusters = sp.clu;

% if ~isfile(fullfile(myKsDir,'wf.mat'))
wf = load(fullfile(myKsDir,'wf'),'wf');
wf = wf.wf;
if ~isfield(wf,'waveFormsMean_flt')
    clearvars wf
    wf = getWaveForms_DW(gwfparams);    %recalculate wf
    save(fullfile(myKsDir,'wf'),'wf');
end
% else
%     wf = load(fullfile(myKsDir,'wf'),'wf');
%     wf = wf.wf;
% end
% if ~isfile(fullfile(myKsDir,'wf_flt.mat'))
%     wf_flt = getWaveForms_filtered_DW(gwfparams);
%     save(fullfile(myKsDir,'wf_flt'),'wf_flt');
% else
%     wf_flt = load(fullfile(myKsDir,'wf_flt'),'wf_flt');
%     wf_flt = wf_flt.wf_flt;
% end
%% get mean/median waveform on tetrode

% determine which template "corresponds to" each cluster, meaning, which template is most represented for each cluster
tempPerClu = findTempForEachClu(sp.clu,sp.spikeTemplates);

% for un = 1:numel(spxtimes)
%     cur_ks_id = session_d.clust_params(un).KS_ID;
%     cur_trode_num = session_d.clust_params(un).tetrode;
%     
%     % mean and median waveforms for all channels on detected tetrode
%     session_d.clust_params(un).wf.mean   = squeeze(wf.waveFormsMean([wf.unitIDs]==cur_ks_id,(cur_trode_num-1)*4+1:cur_trode_num*4,:));
%     session_d.clust_params(un).wf.median = squeeze(wf.waveFormsMedian([wf.unitIDs]==cur_ks_id,(cur_trode_num-1)*4+1:cur_trode_num*4,:));
%     session_d.clust_params(un).wf.mean_flt   = squeeze(wf.waveFormsMean_flt([wf.unitIDs]==cur_ks_id,(cur_trode_num-1)*4+1:cur_trode_num*4,:));
%     session_d.clust_params(un).wf.median_flt = squeeze(wf.waveFormsMedian_flt([wf.unitIDs]==cur_ks_id,(cur_trode_num-1)*4+1:cur_trode_num*4,:));
%     
%     
%     % which spikeTimes the waveforms were calculated with
%     session_d.clust_params(un).wf.spikeTimeKeeps = wf.spikeTimeKeeps(un,:);
%     session_d.clust_params(un).wf.spikeTimeKeeps_flt = wf.spikeTimeKeeps(un,:);
%     
%     % template-approximation used by KS
%     tmp = squeeze(sp.temps(tempPerClu(sp.cids(un)+1)+1,:,:))';
%     session_d.clust_params(un).wf.template = tmp((cur_trode_num-1)*4+1:cur_trode_num*4,:);
% end

for un = 1:numel(spxtimes)
    
    % mean and median waveforms for all channels on detected tetrode
    session_d.clust_params(un).wf.mean   = squeeze(wf.waveFormsMean(un,sp.ycoords==sp.ycoords(session_d.clust_params(un).chan),:));
    session_d.clust_params(un).wf.median = squeeze(wf.waveFormsMedian(un,sp.ycoords==sp.ycoords(session_d.clust_params(un).chan),:));
    session_d.clust_params(un).wf.mean_flt   = squeeze(wf.waveFormsMean_flt(un,sp.ycoords==sp.ycoords(session_d.clust_params(un).chan),:));
    session_d.clust_params(un).wf.median_flt = squeeze(wf.waveFormsMedian_flt(un,sp.ycoords==sp.ycoords(session_d.clust_params(un).chan),:));
    
    % channel with maximum waveform
    session_d.clust_params(un).wf.max_chan = find(session_d.clust_params(un).chan==find(sp.ycoords==sp.ycoords(session_d.clust_params(un).chan)));
    
    % which spikeTimes the waveforms were calculated with
    session_d.clust_params(un).wf.spikeTimeKeeps = wf.spikeTimeKeeps(un,:);
    session_d.clust_params(un).wf.spikeTimeKeeps_flt = wf.spikeTimeKeeps(un,:);
    
    % template-approximation used by KS
    tmp = squeeze(sp.temps(tempPerClu(sp.cids(un)+1)+1,:,:))';
    session_d.clust_params(un).wf.template = tmp(sp.ycoords==sp.ycoords(session_d.clust_params(un).chan),:);
end


%% sort by tetrode

T = struct2table(session_d.clust_params); % convert the struct array to a table
[sortedT, idx] = sortrows(T, 'tetrode'); % sort the table by 'tetrode'
session_d.clust_params = table2struct(sortedT); % change it back to struct
session_d.spikes = session_d.spikes(1,idx);

end




%% Function by Nick Steinmetz (https://github.com/cortex-lab/spikes)
function spikeStruct = loadKSdir(ksDir, varargin)

if ~isempty(varargin)
    params = varargin{1};
else
    params = [];
end

if ~isfield(params, 'excludeNoise')
    params.excludeNoise = true;
end
if ~isfield(params, 'loadPCs')
    params.loadPCs = false;
end

% load spike data

spikeStruct = loadParamsPy(fullfile(ksDir, 'params.py'));

ss = readNPY(fullfile(ksDir, 'spike_times.npy'));
st = double(ss)/spikeStruct.sample_rate;
spikeTemplates = readNPY(fullfile(ksDir, 'spike_templates.npy')); % note: zero-indexed

if exist(fullfile(ksDir, 'spike_clusters.npy'))
    clu = readNPY(fullfile(ksDir, 'spike_clusters.npy'));
else
    clu = spikeTemplates;
end

tempScalingAmps = readNPY(fullfile(ksDir, 'amplitudes.npy'));

if params.loadPCs
    pcFeat = readNPY(fullfile(ksDir,'pc_features.npy')); % nSpikes x nFeatures x nLocalChannels
    pcFeatInd = readNPY(fullfile(ksDir,'pc_feature_ind.npy')); % nTemplates x nLocalChannels
else
    pcFeat = [];
    pcFeatInd = [];
end

cgsFile = '';
if exist(fullfile(ksDir, 'cluster_groups.csv')) 
    cgsFile = fullfile(ksDir, 'cluster_groups.csv');
end
if exist(fullfile(ksDir, 'cluster_group.tsv')) 
   cgsFile = fullfile(ksDir, 'cluster_group.tsv');
end 
if ~isempty(cgsFile)
    [cids, cgs] = readClusterGroupsCSV(cgsFile);

    if params.excludeNoise
        noiseClusters = cids(cgs==0 | cgs==1);

        st = st(~ismember(clu, noiseClusters));
        spikeTemplates = spikeTemplates(~ismember(clu, noiseClusters));
        tempScalingAmps = tempScalingAmps(~ismember(clu, noiseClusters));        
        
        if params.loadPCs
            pcFeat = pcFeat(~ismember(clu, noiseClusters), :,:);
            %pcFeatInd = pcFeatInd(~ismember(cids, noiseClusters),:);
        end
        
        clu = clu(~ismember(clu, noiseClusters));
        cgs = cgs(~ismember(cids, noiseClusters));
        cids = cids(~ismember(cids, noiseClusters));
        
        
    end
    
else
    clu = spikeTemplates;
    
    cids = unique(spikeTemplates);
    cgs = 3*ones(size(cids));
end
    

coords = readNPY(fullfile(ksDir, 'channel_positions.npy'));
ycoords = coords(:,2); xcoords = coords(:,1);
temps = readNPY(fullfile(ksDir, 'templates.npy'));

winv = readNPY(fullfile(ksDir, 'whitening_mat_inv.npy'));

spikeStruct.st = st;
spikeStruct.spikeTemplates = spikeTemplates;
spikeStruct.clu = clu;
spikeStruct.tempScalingAmps = tempScalingAmps;
spikeStruct.cgs = cgs;
spikeStruct.cids = cids;
spikeStruct.xcoords = xcoords;
spikeStruct.ycoords = ycoords;
spikeStruct.temps = temps;
spikeStruct.winv = winv;
% spikeStruct.pcFeat = pcFeat;
% spikeStruct.pcFeatInd = pcFeatInd;
end

