%% Note
% Adjusted from superflex_TD19_Ephys and superflex_TD22_behavior
% -> LEDtrig for video aglinment lasts for the whole duration of paradigm


function superflex_TD23_PMC(phase, animals, COMPort)

%% create header-file, open serial connection to olfactometer.

%"animals" input in superflex_TD23_PMC() needs to be written in a cell array of two strings such as {'x01' 'x02'}

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

    [chapter, session.trialmatrix,ex_vectors_cur]=do_constructTrialMatrix_TD23(phase);  
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


        s1 = ['trialParams' ' '...
     num2str(current_trial(m).odorcue_odor_num)...
            ' ' num2str(current_trial(m).rewardcue_odor_num)...
            ' ' num2str(current_trial(m).drop_or_not),...
            ' ' num2str(chapter.reward_delay),...
            ' ' num2str(current_trial(m).rew_size),...
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
        
        
        
        session(1).data.trials=data;
%         save(protocol_file, 'session');
        for a = 1:size(animals,2)
            save(protocol_file{a}, 'session');
        end
        disp('saved');
        pause(ITD);
       
        toc;
        
        
        
    end %end of paradigm

   
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
