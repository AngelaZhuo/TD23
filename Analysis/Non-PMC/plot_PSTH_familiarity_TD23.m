function f = plot_PSTH_familiarity_TD23(spxtimes,trialtimes,case_num,varargin)
%%
%
%
%% Set defaults
pre     = 1000;
post    = 4000;
binsize = 100;

%% Inputs
if nargin
    for i=1:2:size(varargin,2)
        switch varargin{i}
            case 'pre'
                pre = varargin{i+1};
            case 'post'
                post = varargin{i+1};
            case 'binsize'
                binsize = varargin{i+1};
        end
    end
end

%%% unique case list numbers of odors used
odor_num = [323,324,325]; 
% odor_num(odor_num>325) = [];

label={'familiar','novel1','novel2'};

%% PSTH and Raster

f = figure;
set(gcf, 'Position', get(0, 'Screensize'));

%Loop through cases
for oc = 1:3

    curr_trialtimes = trialtimes(case_num == odor_num(oc));

    x=numel(odor_num);
    %         y=ceil(numel(odor_num)/2);
    p(1)=2;
    p(2)=x;      
    [~, ~, plotaxes(oc)]=mpsth_pj_x(spxtimes,curr_trialtimes,'pre', pre, 'post',post , 'binsz',...
        binsize, 'tb', 1, 'chart', 2,'fr',1,...
        'subplots',[p(1), p(2),oc+x; p(1), p(2),oc]);%'subplots', [4,3,4 ; 4,3,1]
    title(label{oc},'interpreter','none','FontSize',14)          

    %Raster Plot
    hold on
    subplot(p(1),p(2),oc);
end

ylima=get([plotaxes],'YLim');
if x>1
    ylim([plotaxes(1)],[0 max(cellfun(@(x)max(x(:)),ylima))+5]);
    linkaxes([plotaxes(:)],'y');
end
 
  
end
