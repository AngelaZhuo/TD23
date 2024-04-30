%% combine all kinds of figures into one
% MA 2309
%% inputs
% fighd             handles for figures to be combined
% grd               [h w] measures for the h-by-w grid the figures should be integrated in
% figcoor           grid coordinates at which the figures should be integrated into the figure,
%                   if left empty the grid is filled column wise top->bottom and left->right
% figscale          scaling factor, if filled with one value, it applies to all figures,
%                   otherwise one value per figure
%% outputs
% prntfighd         handle to combined figure

%% extensions not yet implemented
% # figcoor
% # scalefunction
% # legend/axislabel/ticklabel toggle

function [prntfighd] = univCombFig(fighd,grd,figvis,figcoor,figscale)
spacer = 0; % space between figures

set(groot, 'DefaultFigureVisible', figvis)
    
if ~exist('figscale','var')
    figscale = 1;
end
% get child figure sizes
for fx = 1:numel(fighd)
    figsz(fx,:) = fighd(fx).Position(3:4);
end

% determine parent figure size
if ~exist('figcoor','var')
    prntsz = [1 1 grd(2)*max(figsz(:,1))+(grd(2)-1)*spacer grd(1)*max(figsz(:,2))+(grd(1)-1)*spacer];
    figcoor = zeros(grd);
    figcoor(1:grd(1)*grd(2)) = 1:grd(1)*grd(2);
else
    warning('Custom figure coordinates not yet implemented!')
    keyboard; return;
end
prntfighd = figure('Position',prntsz);

% array with figure sizes in grid
figszgrd=zeros([grd 2]);
for fx = 1:numel(fighd)
    figszgrd(fx) = figsz(fx,1);
    figszgrd(fx+numel(figcoor)) = figsz(fx,2);
end

% set positions [vertical, horizontal] of child figures in parent
position = nan(numel(fighd),2);
for fx = 1:numel(fighd)
    [rw,clm] = find(figcoor==fx);
    position(fx,2) = prntsz(3) - (sum(figszgrd(rw,clm:grd(2),1)+spacer)-spacer);
    position(fx,1) = prntsz(4) - (sum(figszgrd(1:rw(1),1,2)+spacer)-spacer);
end


% combine figures
for fx = 1:numel(fighd)
    closelast = 0;
    if numel(fighd(fx).Children)==1&&strcmp(fighd(fx).Children(1).Type,'tiledlayout')
        fighd(fx) = tile2Ax(fighd(fx));
        closelast = 1;
    end
    [prntfighd, ~] = CombineFigures(prntfighd, fighd(fx), position(fx,:), figscale);
    if closelast
        close(fighd(fx))
    end
end
end

%% subfunctions

function fhdAx = tile2Ax(fhdTiled)
fhdAx = figure('Position',fhdTiled.Position);
objects = flip(fhdTiled.Children.Children);

axIdx=[];
for ox = 1:numel(objects)
    if  ~isempty(findobj(objects(ox),'Type','Axes'))
        axIdx = [axIdx ox];
    end
end
objNum = diff([axIdx numel(objects)+1]);
for ox = 1:numel(axIdx)
    currAx = axIdx(ox);
    oax = copyobj([objects(currAx:currAx+objNum(ox)-1)],fhdAx);
    for oaxx = 1:numel(oax)
        oax(oaxx).Position = objects(currAx+oaxx-1).Position;
        drawnow
    end
end



if strlength(fhdTiled.Children.Title.String)>0     
    set(groot,'CurrentFigure',fhdAx)
    titleAx = axes('Position',fhdAx.Position.*[0 0 1 1]-[0 0 0 1]);
    titleAx.Color ='none';
    titleAx.Box = 'off';
    titleAx.XAxis.Visible = 'off';
    titleAx.YAxis.Visible = 'off';
    titleAx.Title.String = fhdTiled.Children.Title.String;
    titleAx.Title.FontName = fhdTiled.Children.Title.FontName;
    titleAx.Title.FontSize = fhdTiled.Children.Title.FontSize;
    titleAx.Title.FontWeight = fhdTiled.Children.Title.FontWeight;    
end

end




