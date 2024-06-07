function d = load_KS2_output_in2d_TD23(chan_maps,sessions_of_interest,d)

%% This function loads KS2 output into a d_struct for KS2. the d-struct for all session folder within the root_dir
% All subfunctions called are under "ePhys/single unit/preproc"
% As of 06/06/2024, only x04 and x09 of 20230726 & 20230802 were curated
% sessions_of_interest = [264 269 314 319];
% load the d-struct for KS2 and channel map 
 

%% Mirko Articus 20/12

%  based on create_D_OXT2019.mat by David Wolf 2,2020 and load_KS_output_in2d_TD2019.m; adapted for TD23
% proc_path is the path of the KS2 output of each animal-day session

% sid = [264 269 314 319];
% 
% soi = d_KS2.info(sid);
% 
% for sx = 1:numel(sid)
% 
%     soi(sx).idx = sid(sx);
% 
% end
% 
session_list = {sessions_of_interest.proc_path};

% loc_dir = 'F:\Mirko\DATA\DONE\KS2\curated';

% for s = 1:numel(session_list)
% 
%    cdir = session_list{s};
% 
%    fs = strfind(cdir,filesep);
% 
%    session_list{s} = [loc_dir cdir(fs(end):end)];
% 
% end

regions = {'NAcc' 'OT' 'VTA'};

 

if numel(d.clust_params)==1

    unit_counter = 1;

else

    unit_counter = numel(d.clust_params)+1;

end

 

for ii = 1:length(session_list) %data_list

 

    animal = sessions_of_interest(ii).animal;

    idx = sessions_of_interest(ii).idx;

    curr_id = sessions_of_interest(ii).ID;

    chan_map = chan_maps.(animal);

    curr_dir = session_list{ii};

    cd(curr_dir);

    disp(curr_dir);

 

   %% unit stuff

%    try

    spikes = load_KS_spikes(curr_dir);

   for sp = 1:numel(spikes.clust_params)

        spikes.clust_params(sp).wf = rmfield(spikes.clust_params(sp).wf,{'spikeTimeKeeps','spikeTimeKeeps_flt'});

   end

   
    d.spikes = [];
    d.spikes = cat(2,d.spikes,spikes.spikes);

%    

%     session_d.clust_params(un).wf.spikeTimeKeeps = wf.spikeTimeKeeps(un,:);

%     session_d.clust_params(un).wf.spikeTimeKeeps_flt = wf.spikeTimeKeeps(un,:);

    %%% parse units

    for uc = 1:size(spikes.spikes,2)

       d.clust_params(unit_counter).unit_nr   = unit_counter;

       d.clust_params(unit_counter).session   = curr_id;

       d.clust_params(unit_counter).animal    = animal;

      
% 
%        if contains(animal,'d2')
% 
%            d.clust_params(unit_counter).genotype = 'D2';
% 
%        elseif contains(animal,'d1')
% 
%            d.clust_params(unit_counter).genotype = 'D1';   
% 
%        elseif contains(animal,'dat')
% 
%            d.clust_params(unit_counter).genotype = 'DAT';   
% 
%        end
       d.clust_params(unit_counter).genotype = 'd1';  %TD23 only contains d1-cre 
      

       d.clust_params(unit_counter).session_idx       = idx;

       d.clust_params(unit_counter).KS_ID     = spikes.clust_params(uc).KS_ID;

       d.clust_params(unit_counter).KS_label  = spikes.clust_params(uc).KS_label;

       d.clust_params(unit_counter).chan      = spikes.clust_params(uc).chan;

       curr_tetrode                           = spikes.clust_params(uc).tetrode;

       d.clust_params(unit_counter).trode     = curr_tetrode;

       d.clust_params(unit_counter).region    = regions{chan_map.region(curr_tetrode)};

       d.clust_params(unit_counter).region_coding    = chan_map.region(curr_tetrode);

       d.clust_params(unit_counter).side      = chan_map.side(curr_tetrode);

       d.clust_params(unit_counter).antshift  = chan_map.antshift(curr_tetrode);

       d.clust_params(unit_counter).mean_fr   = spikes.clust_params(uc).mean_fr;

       d.clust_params(unit_counter).std_fr    = spikes.clust_params(uc).std_fr;

       d.clust_params(unit_counter).ref_viols = spikes.clust_params(uc).ref_violations;

       d.clust_params(unit_counter).ISI_mean  = spikes.clust_params(uc).ISI_mean;

       d.clust_params(unit_counter).ISI_median= spikes.clust_params(uc).ISI_median;

       d.clust_params(unit_counter).ISI_cv    = spikes.clust_params(uc).ISI_cv;

       d.clust_params(unit_counter).wf        = spikes.clust_params(uc).wf;

     

    if isfield(d.clust_params,'multi_trode')

       d.clust_params(unit_counter).multi_trode        = spikes.clust_params(uc).multi_trode;

    end

 

    if isfield(d.clust_params,'sparseNbursty')

       d.clust_params(unit_counter).sparseNbursty        = spikes.clust_params(uc).sparseNbursty;

    end

   

    if isfield(spikes.clust_params,'alert')

       d.clust_params(unit_counter).alert        = spikes.clust_params(uc).alert;

    end

       d.map(unit_counter) = sessions_of_interest(ii).idx;

       unit_counter = unit_counter +1;

    end

%    catch
% 
%         warning(['No spikes: ',curr_dir]);      

%    end

    

   fprintf('\n \n');

 

end

end