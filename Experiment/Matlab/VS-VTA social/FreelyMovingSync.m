function FreelyMovingSync(COMPort, minutes)
delete(instrfindall);
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


waitfor(msgbox('Start?'));

            serialdata = fscanf(s, '%s');
        flushinput(s);
        pause(1);
 disp('LEDsync');
        s1 = sprintf('led \r');
        
            fprintf(s,s1);
            
        disp('minute countdown:')
        for i=1:minutes
          disp(minutes-i+1);
        pause(60);
        end
        
 disp('LEDsync');
        s1 = sprintf('led \r');
        
            fprintf(s,s1);

fclose(s);
delete(s)
clear s


beep; pause(0.5); beep; pause(0.5); beep;

disp('time over.');