function pthPre= getPre(varargin)
%Get correct path prefix according to OS you are working on
%   makes scripts work regardless if started from Windows machine in the
%   office or on taweret
if ispc
    ziWs ='W:\group_entwbio\data\Mirko\';
    if isfolder(ziWs)
        pthPre{1} = ziWs;
        pthPre{2} = 'C:\Users\mirko.articus\Documents\';
    else
        pthPre{1} = '';
        pthPre{2} = 'C:\Users\mirko\Documents\';       
    end
elseif isunix
%     if isempty(varargin)
%         pthPre = '/zi-flstorage/data/Mirko/';
%     else % data on server, github repos on local drive
        pthPre{1} = '/zi-flstorage/data/Mirko/';
        pthPre{2} = '/home/mirko.articus/';
%     end
else % later on we might a prefix if working on laptop...
    error('Select current working place (cwp)');
end
end

