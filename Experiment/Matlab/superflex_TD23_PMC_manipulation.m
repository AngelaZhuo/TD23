%% Note
% Adjusted from superflex_TD19_Ephys and superflex_TD22_behavior
% -> LEDtrig for video aglinment lasts for the whole duration of paradigm


function superflex_TD23_PMC_manipulation(phase, animals, COMPort, period)

%% create header-file, open serial connection to olfactometer.

%COMPort = 'COM3'
%"animals" input in superflex_TD23_PMC() needs to be written in a cell array of two strings such as {'x01' 'x02'}
% period refers to the silencing period, either at CS1, CS2, CS1 delay or CS2 delay. Enter number: 1 for CS1, 2 for CS1 delay, 3 for CS2, 4 for CS2 delay 

fname={};
if size(animals,2)<2
    fname{1} = ['A_',animals{1}];   %If there is only one animal in a session, make sure the animal is in box A
else
    fname{1} = ['A_',animals{1}];    %The animal entered first should be in box A and the one entered second should be in box B
    fname{2} = ['B_',animals{2}];      
end

for a = 1:size(animals, 2)
protocol_file{a} = CreateHeader(fname{a});
end

s = SetupSerial(COMPort);

%% selection of parameters according to 'phase' input argument

    [chapter, session.trialmatrix,ex_vectors_cur]=do_constructTrialMatrix_TD23_manipulation(phase);  
    session.trialmatrix_concatenated =  session.trialmatrix;

%% set up some initial conditions

if size(animals,2)>1
    fname_str=strcat(fname{1},'+ ',fname{2});
    protocol_file_str = strcat(protocol_file{1},'+ ',protocol_file{2});
else 
    fname_str=fname{1};
    protocol_file_str = protocol_file{1};
end

session.name = fname_str;
session.time = now;
session.chapter = chapter;
session.header_file = protocol_file_str;
session.silence_period = period;
%session.setup = setup;

current_chapter = 1;
max_trials = chapter.max_trials;

%% Calculate session duration

% Show message box before starting session
waitfor(msgbox({'Start Recording and connect laser.',  'Then start session.'}));
sessionstart = tic;

%% LED Trigger for Video Intan Alignment
        s1 = ['trialParams2' ' '...
     num2str(991)...
            ' ' num2str(0)...
%             ' ' num2str(current_trial(m).drop_or_not),...
%              ' ' num2str(chapter.reward_delay),...
%             ' ' num2str(current_trial(m).rew_size),...
%            ' ' num2str(current_trial(m).odorcue_odor_dur),...
%            ' ' num2str(current_trial(m).rewardcue_odor_dur),...
            ];
       

        try
            
              fprintf(s,s1);
        catch
            disp('Serial error occurred! Try to restart serial and send data...')
            ReleaseArduino(s)
            s = CreateArduinoComm(COMPort);
            fprintf(s,s1);
            %beep
        end
        
              
  pause(5);

%% start session

current_trial=table2struct(session.trialmatrix(1:max_trials,:));%(chapterblock*blocklength-blocklength+1:chapterblock*blocklength,:));  

%% Loop through session
    for m = 1:max_trials
        
        
        tic;
        
        i = m; 
        
        disp('___________________')
        fprintf('Trial %d: ',i);      
         
        
        ITD=(15.5+rand*2);        
 
        switch current_trial(m).trialtype
            case 1
                disp('A->C->Reward')
            case 2
                disp('A->C->NoReward')
            case 3
                disp('A->D->Reward')
            case 4
                disp('A->D->NoReward')
            case 5
                disp('B->C->Reward')
            case 6
                disp('B->C->NoReward')
            case 7
                disp('B->D->Reward')
            case 8
                disp('B->D->NoReward')
        end

% paramsAssemb = tic;


        s1 = ['trialParams4' ' '...
     num2str(current_trial(m).odorcue_odor_num)...
            ' ' num2str(current_trial(m).rewardcue_odor_num)...
            ' ' num2str(current_trial(m).drop_or_not),...
            ' ' num2str(chapter.reward_delay),...            
            ' ' num2str(period),...
            ' ' num2str(current_trial(m).inhibit_or_not),...
            %' ' num2str(current_trial(m).rew_size),...
            %' ' num2str(current_trial(m).odorcue_odor_dur),...
            %' ' num2str(current_trial(m).rewardcue_odor_dur),...
            ];

        
% trialAssemb = toc(paramsAssemb);
% disp('trialAssemb');
% disp(trialAssemb);
      
paramsToBCS = tic; 
        try
            
              fprintf(s,s1);
        catch
            disp('Serial error occurred! Try to restart serial and send data...')
            ReleaseArduino(s)
            s = CreateArduinoComm(COMPort);
            fprintf(s,s1);
            %beep
        end
        TimeForComm = toc(paramsToBCS);
        disp('TimeForComm');
        disp(TimeForComm);
        OClockString = now;
        flushinput(s);
        pause(0.5);
 
        % Start asynchronous reading
        
        % readasync(s);
        
        % Get the data from the serial object
        % the serialdata is in the format 'rewardCode, LickCount'
        %try
          %  serialdata = fscanf(s, '%s');
            
            %         disp(serialdata);
           % TrialEndTime = str2double(serialdata(1));
           % TrialEndTime = str2double(serialdata(2:3));
            fprintf('End of trial: %d \n');
        %catch
%             disp('Serial Error.')
%             ReleaseArduino(s)
%             pause(4);
%             s = CreateArduinoComm(COMPort);
%             
%             ReleaseArduino(s)
%             pause(4);
%             s = CreateArduinoComm(COMPort);
            %beep
            
        %end
        
        %% save and/or update header
        
        data(i).reward_size= current_trial(m).rew_size;
        data(i).curr_trialtype=current_trial(m).trialtype;        
        data(i).curr_odorcue_odor_num = current_trial(m).odorcue_odor_num;
        data(i).curr_rewardcue_odor_num = current_trial(m).rewardcue_odor_num;
        data(i).drop_or_not = current_trial(m).drop_or_not;
        data(i).curr_odorcue_odor_dur = current_trial(m).odorcue_odor_dur;
        data(i).curr_rewardcue_odor_dur = current_trial(m).rewardcue_odor_dur;
        data(i).reward_delay = chapter.reward_delay;
        data(i).OClockString = OClockString;
        data(i).inhibit_or_not = current_trial(m).inhibit_or_not;
        
        
        
        session(1).data.trials=data;
%         save(protocol_file, 'session');
        for a = 1:size(animals,2)
            save(protocol_file{a}, 'session');
        end
        disp('saved');
        pause(ITD);
       
        toc;
        
        
        
    end %end of paradigm


%% Tagging
waitfor(msgbox({'Connect the SMA cables to the blue lasers.',  'Then start tagging.'}));
disp('Start Tagging');
    
%load the case list
load('D:\TD23\Scripts\Matlab\CaseListTag');

    
% define trial parameters 
nt = 20;            %trials per case: 20 for D1 and D2
case_num = [500, 501];     %case number from ephys setup: in D1 and D2 [412, 413, 414, 415] 

    
% construct trialmatrix2
trials = repmat(case_num,1,nt)';
trials = trials(randperm(numel(case_num)*nt));

% pseudorandomness
while CheckRepetitions(trials,3) > 0
   trials = trials(randperm(length(trials)));
end

% fill trialmatrix2 with CaseList information
for tr2 = 1:numel(trials)
   trialmatrix2(tr2).trial_num    = tr2;
   trialmatrix2(tr2).case_num     = trials(tr2);
   trialmatrix2(tr2).laser_name   = CaseListTag([CaseListTag.case_nr] == trials(tr2)).laser_name;
   trialmatrix2(tr2).laser_pattern= CaseListTag([CaseListTag.case_nr] == trials(tr2)).laser_pattern;
   trialmatrix2(tr2).laser_lat    = CaseListTag([CaseListTag.case_nr] == trials(tr2)).laser_lat;
   trialmatrix2(tr2).ITI          = CaseListTag([CaseListTag.case_nr] == trials(tr2)).ITI;
end


%% loop through trials
for tr2 = 1:size(trialmatrix2,2)
    s1 = ['trialParams2' ' '...
     num2str(trialmatrix2(tr2).laser_pattern)...
            ' ' (trialmatrix2(tr2).laser_lat)
            ];
    
%     s1 = sprintf('%s %d %d %d %d %d\r', 'trialParams2',...
%         uint16(trialmatrix2(tr).laser_pattern),...
%         uint16(trialmatrix2(tr).laser_lat));
%     
    % sending parameters to BCS
    try
        fprintf(s, s1);
%         fprintf( s, 'temp \r');
        session.trialmatrix2(tr2).status = 1;
    catch
        disp('Serial error occurred! Try to restart serial...')
        ReleaseArduino(s)
        s = CreateArduinoComm(COMPort);
        fprintf(s, s1);
        fprintf(s, 'temp \r');        
        session.trialmatrix2(tr).status = 0;
        %beep
    end
    
    % printing parameters of trial in command window
    fprintf(     '%d%s   %d\t %d\t %d\n', tr2, ': ', trialmatrix2(tr2).laser_lat, trialmatrix2(tr2).case_num, trialmatrix2(tr2).ITI);
    disp(['Laser=' num2str(trialmatrix2(tr2).laser_pattern) '   odor stim=' num2str(trialmatrix2(tr2).case_num)]);
    disp('-------------------------------------------------------------------------------------------------------------------------------------------------------------------');
    
    % saving trial parameters to file
%     fprintf(fid, '%d%s\t %d\t\t %d\t\t %d\t\t %d\t\t %d\t\t %d\t\t %d\n', tr, ': ',  trialmatrix2(tr).laser_lat, trialmatrix2(tr).odor_dur, trialmatrix2(tr).odor_lat, trialmatrix2(tr).case_num, trialmatrix2(tr).ITI, curr_sound_lat,curr_odor_stim);
    
        tagging(tr2).case_num = trialmatrix2(tr2).case_num;
        tagging(tr2).laser_name = trialmatrix2(tr2).laser_name;
        tagging(tr2).laser_lat = trialmatrix2(tr2).laser_lat;
        tagging(tr2).ITI = trialmatrix2(tr2).ITI;

    
        session(1).tagging.trials = tagging;
        for a = 1:size(animals,2)
            save(protocol_file{a}, 'session');
        end
        disp('saved');
        
    pause((trialmatrix2(tr2).ITI/1e3) + (2*rand));          % tagging ITI increased: 2->3s
end
    
%% LED Trigger for Video Intan Alignment

  pause(5);
  
        s1 = ['trialParams2' ' '...
     num2str(990)...
            ' ' num2str(0)...
%             ' ' num2str(current_trial(m).drop_or_not),...
%             ' ' num2str(chapter.reward_delay),...
%             ' ' num2str(current_trial(m).rew_size),...
            %' ' num2str(current_trial(m).odorcue_odor_dur),...
            %' ' num2str(current_trial(m).rewardcue_odor_dur),...
            ];
       

        try
            
              fprintf(s,s1);
        catch
            disp('Serial error occurred! Try to restart serial and send data...')
            ReleaseArduino(s)
            s = CreateArduinoComm(COMPort);
            fprintf(s,s1);
            %beep
        end
        pause(2);
disp('End of paradigm');

%% End of session
    for a = 1:size(animals,2)
            save(protocol_file{a}, 'session');
    end
    disp('end of session saved');
    sessionduration = toc(sessionstart);
    disp('Session duration');
    disp(sessionduration/60);

    waitfor(msgbox('Stop Intan, disconnect Laser, take out animal, then press ok.'))
    

ReleaseArduino(s)
%beep; pause(0.5); beep; pause(0.5); beep;
pause(0.5);

end





function s = SetupSerial(COMPort)

% setting up serial port
delete(instrfindall);
s = CreateArduinoComm(COMPort);
fprintf( s, 'temp \r');
pause(10);

end


function header_file = CreateHeader(fname)

time = datestr(now,'yymmdd_HHMM');
header_name = [fname, '_', time, '_protocol'];
header_directory = 'D:\TD23\Protocols';
header_file = fullfile(header_directory, header_name);

end


function s = CreateArduinoComm(COMPort)

delete(instrfind)

s=serial(COMPort);

s.baudrate=115200;
s.flowcontrol='none';
s.inputbuffersize=10000;
s.bytesavailablefcnmode = 'terminator';

set(s,'Terminator','CR/LF');
set(s,'DataBits',8);
set(s,'StopBits',2);
set(s, 'TimeOut', 15);


fopen(s);
pause(0.1);
disp('Serial communication is ready')

end

function ReleaseArduino(s)
fclose(s);
delete(s)
clear s
end
