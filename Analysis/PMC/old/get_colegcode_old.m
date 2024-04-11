% get colormap and legendstrings for psth, eucleadian, diameter plots
% showing CS1, CS2 and UCS in separate subplots
function [cmp,lstr,code] = get_colegcode_old(state_str,state_nums,varargin)

% if contains(varargin(1:2:end),'jitter')
%    jitter = varargin{find(contains(varargin(1:2:end),'jitter'))+1};    
% else
%     jitter = false;
% end

if contains(string(varargin(1:2:end)),'manipulation')
    manipulation = varargin{find(contains(varargin(1:2:end),'manipulation'))+1};
else    
   manipulation = false;
end

switch state_str
    case 'CS1'
        legstrs = {["A","B"]};
        colorlabels = {{[1 0 0],[0.0039 0.1765 0.4314]},...
            {[.7 .1 .2],[0.139 0 0.8]}}; % manipulation           
        trialcode = {[5 99 99; 6 99 99]}; %% CS1: A, B        
    case 'CS2'
        legstrs = {["C","D"],...
            ["A \rightarrow C","A \rightarrow D","B \rightarrow C","B \rightarrow D"]};
        colorlabels = {{[1 0 1],[0.0745 0.6235  1.0000]},...
            {[1 0 1],[0.0745 0.6235 1.0000],[0.5882 0.0118 .5882],[0 0 1]},...
            {[0.5882 0.0118 .5882],[0 0 1]}};  % manipulation                 
        trialcode = {[99 7 99; 99 8 99];... % C, D
            [5 7 99; 5 8 99; 6 7 99; 6 8 99]}; %% CS2: AC, AD, BC, BD
    case 'US'
        legstrs = {["R","N"],...
            ["C \rightarrow R","C \rightarrow N","D \rightarrow R","D \rightarrow N"],...
            ["AC1","AC0","AD1","AD0","BC1","BC0","BD1","BD0"]};
        colorlabels = {{[0.9882    0.7922 0],[0.3373    0.7216    0.0667]},...
            {[0.9882    0.7922 0],[0.3373    0.7216    0.0667],[0.9804    0.3843    0.1255],[0.0039    0.3216    0.0863]},...
            {'m','b','r','g','y','c',[.5 .6 .7],[.8 .2 .6]},...
            {[0.9804    0.3843    0.1255],[0.0039    0.3216    0.0863]}};% manipulation                 
        trialcode = {[99 99 1; 99 99 0];...
            [99 7 1; 99 7 0; 99 8 1; 99 8 0];... 
            [5 7 1; 5 7 0; 5 8 1; 5 8 0; 6 7 1; 6 7 0; 5 8 1; 5 8 0]}; 
end

lstr = legstrs{state_nums};
code = trialcode{state_nums};

if ~manipulation
    cmp = colorlabels{state_nums};
else
%     cmp = cellfun(@(x) x*.3,cmp,'un',0);
    cmp = colorlabels{end};
    lstr = lstr + " manip";
end
end
