% get colormap and legendstrings for psth, eucleadian, diameter plots
% showing CS1, CS2 and UCS in separate subplots
function [cmp,lstr,code] = get_colegcode(state_str,state_nums,varargin)
% defaults
manipulation = false;
para = [];
% if contains(varargin(1:2:end),'jitter')
%    jitter = varargin{find(contains(varargin(1:2:end),'jitter'))+1};
% else
%     jitter = false;
% end

if any(contains(string(varargin(1:2:end)),'manipulation'))
    manipCode = varargin{find(contains(varargin(1:2:end),'manipulation'))*2};
    if numel(manipCode)>1
        manipulation = false;
    else
        manipulation = manipCode;
    end
end

if any(contains(string(varargin(1:2:end)),'paradigm'))
    para = varargin{find(contains(varargin(1:2:end),'paradigm'))*2};
end


switch state_str
    case 'CS1'
        legstrs = {["A","B"]};
        colorlabels = {{[1 0 0],[0.0039 0.1765 0.4314]},...%% A, B
            {[1 .3 0],[0 .2 1]}}; % A, B manipulation
        trialcode = {[5 99 99; 6 99 99]}; % A, B
        
        
    case 'CS2'
        legstrs = {["C","D"],...
            ["A \rightarrow C","A \rightarrow D","B \rightarrow C","B \rightarrow D"]};
        colorlabels = {{[1 0 1],[0.0745 0.6235  1.0000]},... % C, D
            {[1 0 1],[0.0745 0.6235 1.0000],[0.5882 0.0118 .5882],[0 0 1]},... % AC, AD, BC, BD
            {[0.5882 0.0118 .5882],[0 0 1]}};  % C, D manipulation
        trialcode = {[99 7 99; 99 8 99];... % C, D
            [5 7 99; 5 8 99; 6 7 99; 6 8 99]}; % AC, AD, BC, BD
        
    case 'US'
        legstrs = {["R","N"],...
            ["C \rightarrow R","C \rightarrow N","D \rightarrow R","D \rightarrow N"],...
            ["AC1","AC0","AD1","AD0","BC1","BC0","BD1","BD0"]};
        colorlabels = {{[0.9882    0.7922 0],[0.3373    0.7216    0.0667]},... % R, N
            {[0.9882    0.7922 0],[0.3373    0.7216    0.0667],[0.9804    0.3843    0.1255],[0.0039    0.3216    0.0863]},... % CR, CN, DR, DN
            {'m','b','r','g','y','c',[.5 .6 .7],[.8 .2 .6]},... %  AC1, AC0, AD1, AD0, BC1, BC0, BD1,BD0
            {[0.9804    0.3843    0.1255],[0.0039    0.3216    0.0863]}};% R, N manipulation
        trialcode = {[99 99 1; 99 99 0];... % R, N
            [99 7 1; 99 7 0; 99 8 1; 99 8 0];... % CR, CN, DR, DN
            [5 7 1; 5 7 0; 5 8 1; 5 8 0; 6 7 1; 6 7 0; 5 8 1; 5 8 0]}; %  AC1, AC0, AD1, AD0, BC1, BC0, BD1,BD0
end

lstr = legstrs{state_nums};
code = trialcode{state_nums};

if ~manipulation
    cmp = colorlabels{state_nums};
else
    %     cmp = cellfun(@(x) x*.3,cmp,'un',0);
    cmp = colorlabels{end};
    lstr = lstr + " - manip";
end

if numel(manipCode) ==1
if strcmp(para,'exciteA')
    if any(ismember(code(:),5))
        bTr =any(ismember(code,[6 10]),2);
        code(bTr,:) = [];
        cmp(bTr) = [];
        lstr(bTr) = [];
    else
        for sx=1:numel(cmp)
            code(sx,1)=5;
            lstr(sx) = "A \rightarrow " + lstr(sx);
        end
    end
elseif strcmp(para,'exciteB')
    if any(ismember(code(:),[6 10]))
        aTr =any(ismember(code,5),2);
        code(aTr,:)=[];
        cmp(aTr) = [];
        lstr(aTr)=[];
    else
        for sx=1:numel(cmp)
            code(sx,1)=6;
            lstr(sx) = "B \rightarrow " + lstr(sx);
        end
    end
end
end