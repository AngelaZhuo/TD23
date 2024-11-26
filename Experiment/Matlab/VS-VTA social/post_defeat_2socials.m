function post_defeat_2socials(COMPort, fname)
%% Script runs the longer version of the reappraisal paradigm (JR & DW 2022)
% compatible with flex_arduino
% Modified from post_defeat_4socials
% Trialstructure:
% 60 trials - 30 per odor: familiar CD1 (post defeat) and novel CD1

protocol_file = CreateHeader(fname);
session.name = fname;
session.time = now;
session.header_file = protocol_file;

s = CreateArduinoComm(COMPort);
%% create trialmatrix
fprintf('Creating new trialmatrix for this animal and paradigm \n');
load('D:\Experimental Control\OFC-AI Cohort\CaseList.mat','CaseList');            
% Block 1: define trial parameters
nt = 30;            %trials per odor
case_num = [400, 401];     %case number from ephys setup

% construct trialmatrix
trials = repmat(case_num,1,nt)';

% random shuffle
trials = trials(randperm(length(trials)));

% pseudorandomness
while CheckRepetitions(trials,3) > 0
   trials = trials(randperm(length(trials)));
end

for tr = 1:numel(trials)
    trialmatrix(tr).trial_num    = tr;
    trialmatrix(tr).case_num     = trials(tr);
    trialmatrix(tr).case_name    = CaseList([CaseList.case_nr] == trials(tr)).odor_name;
    trialmatrix(tr).odor_dur     = CaseList([CaseList.case_nr] == trials(tr)).odor_dur;
    trialmatrix(tr).odor_num     = CaseList([CaseList.case_nr] == trials(tr)).odor_num;
    trialmatrix(tr).odor_lat     = CaseList([CaseList.case_nr] == trials(tr)).odor_lat;
%     if tr ==1;
%         trialmatrix(tr).laser_pattern= 99;
%     else
        trialmatrix(tr).laser_pattern= CaseList([CaseList.case_nr] == trials(tr)).laser_pattern;
%     end
    trialmatrix(tr).laser_lat    = CaseList([CaseList.case_nr] == trials(tr)).laser_lat;
    trialmatrix(tr).air_lat  = CaseList([CaseList.case_nr] == trials(tr)).air_lat;
    trialmatrix(tr).ITI          = CaseList([CaseList.case_nr] == trials(tr)).ITI;
end
            
session.trialmatrix = trialmatrix;

%% wait for start
% calculate recording duration based on ITI, adding 10 t_reps at the
% beginning and also adding baseline for paradigm 2. All in msecs like ITI
recdur     = sum([session.trialmatrix.ITI])+60+2e3*numel(session.trialmatrix);
recdur_min = floor(recdur/1e3/60);
recdur_sec = mod(recdur/1e3,60);

waitfor(msgbox({['Protocol Time: ',num2str(recdur_min),':',num2str(recdur_sec),' min'],...
    'Start Session?'}));

%% start session

for tr = 1:size(session.trialmatrix,2)
    
    if tr == 1 %%
        disp('start LED sync in ...');
        for cx=1:10
           disp(10-cx);
           pause(1);
        end
        disp('LEDsync');
        s1 = sprintf('led \r');  
        fprintf(s,s1);
        disp('60 sec baseline')
        pause(60);
    end
    
    s1 = sprintf('%s %d %d \r', 'o',...
            uint16(session.trialmatrix(tr).odor_num),...
            uint16(session.trialmatrix(tr).odor_dur)...
            );

    fprintf(s,s1);            
    session.trialmatrix(tr).status = 1;

        
    % printing parameters of trial in command window
    fprintf('Trial#: %d\t Case:%d\t Odor:%s\t Odor_lat:%d\t Laser latency:%d\t Status:%d\t \n',...
        tr, session.trialmatrix(tr).case_num, session.trialmatrix(tr).case_name, session.trialmatrix(tr).odor_lat,...
        session.trialmatrix(tr).laser_pattern, session.trialmatrix(tr).status);
    
    session.trialmatrix(tr).ITI_rand=(session.trialmatrix(tr).ITI/1e3) + (2*rand);
    pause(session.trialmatrix(tr).ITI_rand);
end

    


%% LED stim end of recording
s1 = sprintf('led \r');
fprintf(s,s1);  
            
%% save protocol
save(protocol_file,'session');

%% exit
waitfor(msgbox('Release Arduino?'));
ReleaseArduino(s)
beep; pause(0.5); beep; pause(0.5); beep;


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
%header_directory = 'C:\Drive\Headerfiles';
header_directory = 'D:\protocols\';
header_file = fullfile(header_directory, header_name);

end


function s = CreateArduinoComm(COMPort)

delete(instrfind)

s=serial(COMPort);

s.baudrate=9600;
s.flowcontrol='none';
s.inputbuffersize=10000;
s.bytesavailablefcnmode = 'terminator';

set(s,'Terminator','CR/LF');
set(s,'DataBits',8);
set(s,'StopBits',2);
set(s, 'TimeOut', 12);


fopen(s);
pause(0.1);
disp('Serial communication is ready')

end

function ReleaseArduino(s)
fclose(s);
delete(s)
clear s
end




