function d = SessionDfromKS_TD23(KSdir,clustering,maps)
%% MScheller 120921.
%%Mirko Articus 220110: customized
%AZ 231011 modified from SessionDfromKS_TD19
recompute = false;
warning_msg = ''; %-> collects warning messages about session, put into d.info

protocol_dir = [KSdir filesep];%'/zi-flstorage/data/Max/H18protocols/';

odorchan = 1;%2;
rewchan = 2;%3;
% lickchan = 6;%3;
% sniffchan = NaN; %1
% laserchans = [3 5]; % [VTA VS] %[6 8];
laserchans = [4]; %TD19 the laserchans were [3 5]
% min_lick_length = 20; %No lick data in TD23
% min_lick_interval = 20;
region_names = {'NAcc' 'OT' 'VTA'};
drop_latency=0.52; %MA: drop_latency = 0.25;
odor_latency = 0.09; %MA: odor_latency = 0.07;

%%
sc=1; %sessionindex

cd(KSdir)
[~, sessionID] = fileparts(KSdir);
temp = strsplit(sessionID, '_');
animal = temp{1};
sessiondate = temp{2};
sessionID %= [animal '_' sessiondate] %sessionID(1:12)
% -> full session ID works to map data to right session, even if multiple sessions per day


%% load files
tic
disp('load aux-files')



protocols = dir(protocol_dir);
protidx = contains({protocols.name},'protocol.mat');%contains({protocols.name}, sessionID);

sessionfiles = dir(KSdir);
dx = contains({sessionfiles.name},'_digital');
dig = load([KSdir filesep sessionfiles(dx).name]);

% adcx = find(contains({sessionfiles.name},'adc')); %TD23 cohort does not have adc(sniff) data 
% adc = load([KSdir filesep sessionfiles(adcx).name]);

% sniffx = find(contains({sessionfiles.name},'sniff'));

%% check digital and protocol files

if sum(protidx)>1 % more than one protocolfile for the animal on that day?
    warning('more than one protocol.')
    d= nan;
    return;
elseif sum(protidx)==0
    warning('no protocol found')
    odorchan = 3; % take reward timestamps as trials
    protocol = ConstructProtocolFromDigitalTD19(dig, sessionfiles(dx).name);
    if ~isstruct(protocol)
        d = nan;
        return;
    end
    
else
    protocol = load([protocol_dir protocols(protidx).name]);
    
end
events = protocol.session.data.trials;

% if length(events) ~= length(find(diff(dig.dchannels(:,odorchan))==1))/2
%
%     warning('mismatch of digital and protocol file')
% % d = nan;
% % return;
% end

samplerate = dig.sample_rate;

toc

%% load ks output
tic
disp('import KS output')
d = load_KS_spikes_laser_TD19([KSdir filesep clustering],laserchans);


toc

%% info
tic
disp('construct info, events, licks, laser etc in d')

d.info(sc).animal = animal;
d.info(sc).date = sessiondate;
d.info(sc).tag = protocol.session.chapter.case;
d.info(sc).superflex_parameters = protocol.session.chapter;
d.info(sc).fs = samplerate;

%     d.info(sc).KS.channelposition = channelposition;

%% lick and laser
dchannels = dig.dchannels(1:30:end, :); %downsampling 30K/s -> 1K/s
% adcchannels=adc.adcchannels(1:30:end,:);


%% laser stuff
if ~isempty(laserchans)
    laser{1} = find(diff(dchannels(:,laserchans(1)))==1)/1000;
%     laser{2} = find(diff(dchannels(:,laserchans(2)))==1)/1000;
    d.laser{sc} = laser;
end

 %% lick stuff
% if size(dchannels,2)==lickchan %~isempty(lickchan) && ~isempty(events)
%     
%     licktrace = dchannels(:,lickchan); %adcchannels(:,2);
% 
% %     licktrace = licktrace>2;% -> what for??
%     
%     lick_on = (find(diff(licktrace)==-1));
%     lick_off = (find(diff(licktrace)==1));
%     
%     
%     
%     while lick_off(1) < lick_on(1)
%         lick_off(1) = [];
%     end
%     while lick_on(end) > lick_off(end)
%         lick_on(end) =[];
%     end
%     
%     lick_dur = lick_off-lick_on;
%     lick_on = lick_on(lick_dur>min_lick_length);
%     lick_off = lick_off(lick_dur>min_lick_length);
%     
%     if isempty(lick_on)
%         warning('no licking')
%         
%         %         continue;
%     end
%     
%     ILI = diff(lick_on);
%     licks = lick_on(logical([1; ILI>min_lick_interval]))/1000;
%     
%     d.licks{sc} = licks;
% else
%     d.licks{sc} = [];
% end
%% odor and reward stuff

odortrace = dchannels(:,odorchan);
fv_on = find(diff(odortrace)==1)/1000+odor_latency;
fv_off = find(diff(odortrace)==-1)/1000+odor_latency;
fv_dur=fv_off-fv_on;

try 
    fv_dist = [0;diff(fv_on)];
catch
    fv_dist = [0 diff(fv_on)];
end


rewtrace = dchannels(:, rewchan);
rew = find(diff(rewtrace)==1)/1000+drop_latency;


% remove false signals detected..
% fv
ToDelete = find( fv_dur >1.3 | fv_dur < 1.2);

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

if ToDelete
    warning_msg = append(warning_msg,[num2str(numel(ToDelete)) ' false fvon/off detected']);
end

fv_on(ToDelete)= [];
fv_off(ToDelete)= [];
fv_dur(ToDelete)= [];

if numel(events)~=numel(fv_on)/2
    if numel(fv_on)/2 == 50 || numel(fv_on)/2 ==100
        waitfor(msgbox('03 or 06 session causes problems, adjust script'))
    else
        error('missmatch protocol and digital file for fv_on/off!')
        %         d=nan;
        %         return
    end
end
% reward
ToDelete = find(rew<fv_on(1) | rew>(fv_off(end)+events(1).reward_delay/1000+drop_latency));
rew(ToDelete)=[];

if ToDelete
    warning_msg = append(warning_msg,' -- ',[num2str(numel(ToDelete)) ' false reward(s) before or after session detected']);
end

if numel(rew)>numel(fv_on)/4
    error('extra reward(s) during session!')
    %     d=nan;
    %     return
elseif numel(rew)<numel(fv_on)/4
    error('reward(s) missing!')
    %     d=nan;
    %     return
end


%redundant
%
% if length(events) ~= length(fv_on)/2
%
%     warning('mismatch of digital and protocol file')
%     error('mismatch of digital and protocol file')
%
% end

%% protocol stuff
%%
for i=1:length(events)
    % OC
    events(i).fv_on_odorcue = fv_on(i*2-1);
    events(i).fv_off_odorcue = fv_off(i*2-1);
    if events(i).curr_odorcue_odor_num == 5
        events(i).curr_odorcue_odor ='A_Carvone(+)';
    else
        events(i).curr_odorcue_odor ='B_Carvone(-)';
    end
    % RC
    events(i).fv_on_rewcue = fv_on(i*2);
    events(i).fv_off_rewcue = fv_off(i*2);
    if events(i).curr_rewardcue_odor_num ==7
        events(i).curr_rewcue_odor ='C_MethylAn';
    else
        events(i).curr_rewcue_odor ='D_Eugenol';
    end
    %jitter
    events(i).jitter_OC_RC = (events(i).fv_on_rewcue - events(i).fv_off_odorcue)-1.2;
    
    reward_time = rew(rew>fv_on(i*2) & rew<fv_off(i*2)+2);
    if ~isempty(reward_time)
        events(i).reward_time = reward_time(1);
    else %add fake reward_time to have a clear timestamp
        events(i).reward_time = events(i).fv_off_rewcue+events(i).reward_delay/1000;
    end
    
    if ~isempty(d.licks{sc})
        if i<length(events)
            events(i).licks = licks(licks>fv_on(i) & licks<fv_on(i+1));
        else
            events(i).licks = licks(licks>fv_on(i) & licks<fv_off(i)+3);
        end
    end
    
end

% remove unnecessary infos
events = rmfield(events, 'curr_odorcue_odor_dur');
events = rmfield(events, 'curr_rewardcue_odor_dur');
events = rmfield(events, 'OClockString');
events = rmfield(events, 'reward_delay');
events = rmfield(events, 'reward_size');


% pre and post session rewards ("stage one")
%
% if ~isempty(rew)
% frame_rew{1} = rew(rew<fv_on(1));
% frame_rew{2} = rew(rew>fv_off(end)+2);
%
%
% d.frame_rew{sc} = frame_rew;
% else
%     d.fram_rew{sc} = [];
% end



d.events{sc} = events;
d.info(sc).warning = warning_msg;
d.info.ID = [];

toc

%% unit-wise stuff
for ux=1:length(d.clust_params)
    
    d.map(ux) = sc;
    d.clust_params(ux).mean_fr = getMeanFreqTD19(d.spikes{ux},d.events{sc});
    d.clust_params(ux).animal = animal;
    d.clust_params(ux).date = sessiondate;
    d.clust_params(ux).ID = ux;
    d.clust_params(ux).session = sessionID;
    d.clust_params(ux).tag = protocol.session.chapter.case;
    tetrode = d.clust_params(ux).tetrode;
    try
        d.clust_params(ux).region_coding = maps.(animal).region(tetrode);%d.clust_params(ux).tetrode);
        d.clust_params(ux).region = region_names{maps.(animal).region(tetrode)};%d.clust_params(ux).tetrode)};
    catch
        d.clust_params(ux).region_coding = 99;
        d.clust_params(ux).region = 'LFPorOFF';
        warning_msg = ['Unit ' num2str(ux) ' on tetrode ' num2str(tetrode) ' detected!'];
        warning(warning_msg);%d.clust_params(ux).tetrode
        d.info(sc).warning = append(d.info(sc).warning,'--',warning_msg);
        disp(getReport(MException.last))
    end
    if contains(animal,'d1')
        gt ='D1';
    elseif contains(animal,'d2')
        gt='D2';
    elseif contains(animal,'da')
        gt='DAT';
    end
    d.clust_params(ux).genotype = gt;
    d.clust_params(ux).side = maps.(animal).side(tetrode);     %side=1 indicates left himisphere and side=2 indicates right hemisphere
%     d.clust_params(ux).antshift = maps.(animal).antshift(tetrode);  %antshift=1 indicated that the tetrode shifted anterior in MA's cohort      
    
    
    for rx=1:length(laserchans)
        if rx==2
            d.clust_params(ux).crosstagVS = CrossTagTD19(d,ux, rx, 0);
        else
            d.clust_params(ux).crosstagVTA = CrossTagTD19(d,ux, rx, 0);
        end
    end
    
    if ux>1
        d.map(ux) = 0;
    end
end


end

