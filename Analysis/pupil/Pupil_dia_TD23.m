%% Modified from load_pupil_dia.m
% This is the function for computing the diameter from the 8point coordinate output from DLC, then the diameter
% is aligned to the IR signal from intan digital file  

clear

load '\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD23\D-struct\d'
%After loading the d-struct, note which sessiosn should be excluded

%Reappraisal and freely-moving data had been excluded
csv_path = '\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD23\Pupil\TD23_8point_coord';  
Videolist_csv = [];
% for csv = 1:numel(dir(csv_path))
%     Videolist_csv = cat(1,Videolist_csv, getAllFiles(csv_path{csv},'*filtered.csv',1));
%     Videolist_csv(contains(Videolist_csv,'short')) = [];
% end
Videolist_csv =  getAllFiles(csv_path,'*filtered.csv',1); %'short' folders werer not created in the DLC analysis

% Session_filter(Videolist_csv)
% Used the filtered 8point coordinates 

savedir = '\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD23\Pupil\plots\dia_trace';
%the savedir is the directory where pupil raw trace plot is saved


vid_path = '\\zistfs02.zi.local\NoSeA\Angela\TD23_videos';
Videolist = [];
% for vd = 1:numel(vid_path)
%     Videolist = cat(1,Videolist, getAllFiles(vid_path{vd},'*.wmv',1));
% end
Videolist = getAllFiles(vid_path, '*.wmv',1);
Videolist(~contains(Videolist,'Pupil')) = [];
Videolist(contains(Videolist, {'reappraisal'})) = [];  %remove reappraisal data


dig_path = ["\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\Combined_DigFiles\20220908_TD22_Devaluation"...
            "\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\Combined_DigFiles\20220909_TD22_Devaluation"...
            "\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\Combined_DigFiles\20220910_TD22_Devaluation"...
            "\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\Combined_DigFiles\20220917_TD22_Extinction"];
Diglist = [];
for dg = 1:numel(dig_path)
    Diglist = cat(1,Diglist, getAllFiles(dig_path{dg},'*digital.mat',1));
end
Diglist(contains(Diglist, 'y11_y16_220917')) = [];


protocol_path = ["\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\RAW\20220908_TD22_Devaluation"...
                "\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\RAW\20220909_TD22_Devaluation"...
                "\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\RAW\20220910_TD22_Devaluation"...
                "\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\RAW\20220917_TD22_Extinction"];
Protocollist = [];
for dg = 1:numel(protocol_path)
    Protocollist = cat(1,Protocollist, getAllFiles(protocol_path{dg},'*protocol.mat',1));
end
Protocollist(contains(Protocollist,{'Y11_220917','Y16_220917'})) = [];


%% loop to get pupil diameter traces

ID = 1:numel(Videolist_csv); 
% ID(28) = [];    %y11-20220917_143611 pupil file was corrupted


for vx = ID
    

    % Load DLC-output data and calculate diameters.
    likelihood_threshold = 0.99;

    %8point
    pupil_dia = pupil_load_and_get_diameter(Videolist_csv(vx), likelihood_threshold, savedir); 
    
    % scrubbing and stuff (copy from Mirko Articus);does not use here
    
    % session_index =  hi
    
    % parse pupil diameter traces to d-struct
    
    [~,video_name] = fileparts(Videolist{vx});
    current_animal_name = video_name(1:3);
    current_date = video_name(5:12);
    
    d_info_index = find(ismember({d.info.animal}, current_animal_name) & ismember({d.info.date}, current_date));
  
    d.pupil(d_info_index).raw_trace = pupil_dia.d_mean;


    % visual control
    hold on
    plot(gca, d.pupil(d_info_index).raw_trace);
    title([current_animal_name,' on the ',current_date]);
    exportgraphics(gcf,fullfile('\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\plots\Diameter\08.09-17.09_thr0.99',[current_animal_name,'_',current_date,'.png']))
    close all;
    
end

    save('\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\D-struct\d.mat','d');


%% Synchronize digitals with the protocol information
% The following was copied and modified from load_dig_and_prot.m under \\zisvfs12\Home\yi.zhuo\Documents\GitHub\TD22\Analysis\d_struct\

for vx = 1:numel(Videolist)

    % find the digital file from this session
    [~,video_name] = fileparts(Videolist{vx});
    current_animal_name = video_name(1:3);
    current_date = video_name(5:12);
    
    d_info_index = find(ismember({d.info.animal}, current_animal_name) & ismember({d.info.date}, current_date));
    
    % load the digital file
    load(Diglist{contains(Diglist,current_animal_name) & contains(Diglist,current_date)});
    
    % load the protocol file
    load(Protocollist{contains(Protocollist,current_animal_name) & contains(Protocollist,current_date)});
    
    % we want to create "events" for every session having the information
    % for every trial including timestamps for cues and rewards
    events = session.data.trials;

    % first we find the final valve switches and align to the
    % trial-structure
    
    % CAVE: CHOOSE RIGHT CHANNEL FOR FV! add odor latency
    odor_latency = 0.09 ; % EPhys double setup
    fvtrace = dchannels(:,1); 

    freq = 20000; % sample rate
    fv_off = find(diff(fvtrace)== -1)/freq + odor_latency;
    fv_on = find(diff(fvtrace)== 1)/freq + odor_latency;
    
    
    
% %     If MaxTrialNum < 150, e.g. sessions y07&y08-20220917, y17&y18-20220731
%     if vx == 15 | vx == 16
%         % Make the number of fv_on equal to the number of fv_off. 
%       fv_on = fv_on(1:numel(fv_off));
%       
%     % Make the number of on pair so that we have only complete trials
%         if mod(numel(fv_on), 2) ~= 0
%             fv_on(end) = []; fv_off(end) = [];
%         end
%         session.data.trials(numel(fv_on)/2 + 1 : end) = [];
%     end
            
 
    
    fv_dur = fv_off-fv_on;

    
    % remove false signals detected..
    ToDelete= find( fv_dur >1.3 | fv_dur < 1.2);
    
    fv_on(ToDelete)= [];
    fv_off(ToDelete)= [];
    fv_dur(ToDelete)= [];
    
    % Sanity check: detected number of fv onsets equal to trials passed?
    MaxTrialNum = length(session.data.trials); 
    if length(fv_on)/2 ~= MaxTrialNum
       warning(['incorrect number of fv_onsets (~=MaxTrialNum) in ' protocolfile '.mat'])
    end
   
    % Sanity check: same number of fv ons and offs...
    if length(fv_on)~=length(fv_off)
       error(['unequal number of fv_on and fv_off in ' protocolfile '.mat'])
    end

    % LW Feb 2020: 1 - 149 trial loop 
    fv_on_odorcue = fv_on(1:2:end); 
    fv_on_rewcue = fv_on(2:2:end); 

    fv_off_odorcue = fv_off(1:2:end); 
    fv_off_rewcue = fv_off(2:2:end);

    % dur_odorcue = fv_dur(1:2:end); 
    % dur_rewcue = fv_dur(2:2:end); 

    % CHECK odorcue - rewcue assignment ... 
    fv_on_diff_OdorRew = fv_on_rewcue - fv_on_odorcue; 
    ToDelete = find( fv_on_diff_OdorRew >3.70 | fv_on_diff_OdorRew < 2.3);
    fv_on_diff_OdorRew(ToDelete) = []; 

    if length(fv_on_diff_OdorRew) ~= length(session.data.trials)
       error(['incorrect number of Odor Cue - Rew Cue pairs (~=MaxTrialNum) in ' protocolfile '.mat'])
    end

    % CAVE: CHOOSE RIGHT CHANNEL FOR REWARD SIGNAL! 
    droptrace = dchannels(:,2)+ dchannels(:,3); %+dchannels(:,4)for devaluation

    % drop latency - depending on setup - CHECK!
    drop_latency = 0.52;           %second %0.1;

    % find drops in derivative of digital trace...(+add drop latency)
    drops = find(diff(droptrace)==1)/freq + drop_latency;

    drops(drops < fv_on(1))=[];
    %drops(drops>fv_on(end)+5)=[];
    
    for tr=1:numel(session.data.trials)

      events(tr).fv_on_odorcue = fv_on_odorcue(tr);
      events(tr).fv_off_odorcue = fv_off_odorcue(tr);
      events(tr).fv_on_rewcue = fv_on_rewcue(tr);
      events(tr).fv_off_rewcue = fv_off_rewcue(tr);
    
      if tr ~= numel(session.data.trials)
          % DROPS
          events(tr).reward_time = drops(drops>fv_on_odorcue(tr) & drops<fv_on_odorcue(tr+1));

          % CONTROL: check if there is only one drop in interval..
          if numel(drops(drops>fv_on_odorcue(tr) & drops<fv_on_odorcue(tr+1))) > 1
        %      error(['idx' cell2mat(soi_idx(i)) ':' 'Trial with more than one drop detected in ' protocolfile '.mat'])
             dropcurr = drops(drops>fv_on_odorcue(tr) & drops<fv_on_odorcue(tr+1));
             events(tr).reward_time = dropcurr(1);
          end

      else % for last trial ( = trial 150) 

        % temp = all drops after last fv onset..
        temp = drops(drops>fv_on_odorcue(tr));
        % DIFF_odor_drop = time between last fv on and first droptrace afterwards..

        try
            DIFF_odor_drop = temp(1)-fv_on_odorcue(tr); 
            % this if condition makes sure that the artificial dropsignal (occuring when
            % serial communication is closed) is not considered as a drop...
            if any(temp) && DIFF_odor_drop < 6 
              events(tr).reward_time = temp(1);
            end

        catch 
            events(tr).reward_time = [];
        end 

      end 


    end
    
    
    % parse to d
    d.events{d_info_index} = events;
    vx;
end

  save('\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\D-struct\d.mat','d');
        

%% Alignment of Intan timestamps to the video timeseries
% get saved [fvon(1) fvoff(last)] for videos
% copied sections from VidIntanAlign.m
% if the automatic detection of red LED start signal in the video does not work here, align_by_hand.m can allow entering the start signal frame by hand 

control_button = 1;

IX = 1:numel(Videolist); 
% IX(28) = [];    %y11-20220917_143611 pupil file was corrupted
        
for vx = IX

    % find the digital file from this session
    [~,video_name] = fileparts(Videolist{vx});
    current_animal_name = video_name(1:3);
    current_date = video_name(5:12);
    
    d_info_index = find(ismember({d.info.animal}, current_animal_name) & ismember({d.info.date}, current_date));
    
    % load the digital file
    load(Diglist{contains(Diglist,current_animal_name) & contains(Diglist,current_date)});
    
    % find the intan signal for switching the light on
    freq = 20000; % samplerate
    led_trace = dchannels(:,5);
    led_on_timestamp = find(diff(led_trace)==1)/freq;
    led_off_timestamp = find(diff(led_trace)==-1)/freq;
    
        %If there exists more than one led_on_timestamp and/or led_offtimestamp
        if (length(led_on_timestamp) > 1 || length(led_off_timestamp)> 1 && led_on_timestamp(1) < led_off_timestamp(1))
            led_on_timestamp(2:end) = [];
            led_off_timestamp(2:end) = [];
        end
            
    assert(led_on_timestamp < d.events{d_info_index}(1).fv_on_odorcue); %assert fucntion gives a sanity check
    
    % load the video:
    % construct a multimedia reader object, that can read in video data from a
    % multimedia file.
    v = VideoReader(Videolist{contains(Videolist,current_animal_name) & contains(Videolist,current_date)});
    
    framecounter = 1; % for creating "bright1" variable ...
    dur = 100; % in s; v.CurrentTime is in s ...
    % dur = 40; %before, changed to 100 to capture late LED-Triggers
    
    if control_button == 1 
        f = figure;
        suptitle('PLOT - FIND FIRST TRIGGER ONSET');
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    end
    while v.CurrentTime < dur % read first minute
        % read predefined frames
        video = readFrame(v);

        % bright1 = variable containing mean intesity values frame by frame ...
        bright1(framecounter) = mean(video(:,:,1),'all'); %the readFrame gives an output of a video frame
                                                          %video(pixel# on the width:pixel# on the length:RGB values). Here (:,:,1) selects the R value of all the pixels
        
        % plot the intensity values for visual control ...
        if control_button
            plot(gca, bright1);
        end

        % modify counter ...
        framecounter=framecounter+1;
    end
    
    diff_bright1 = diff(bright1);
    [~,FrameBegin] = max(diff_bright1); % highest brightness difference is where the first frame begins
    
    % visual control
    hold on
    plot(gca,FrameBegin,bright1(FrameBegin),'*','MarkerSize',12,'MarkerFaceColor','g','MarkerEdgeColor','r');
    title([current_animal_name,' on the ',current_date]);
    exportgraphics(gcf,fullfile('\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\plots\Video_LED_brightness\31.07-02.08_PMC\',[current_animal_name,'_',current_date,'.png']))
    close all;

    d.info(d_info_index).LED_on_trigger_intan = led_on_timestamp;
    d.info(d_info_index).LED_on_trigger_camera = FrameBegin/10; % convert from samples to seconds
    
    vx;
end

%  save('\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\D-struct\d','d');