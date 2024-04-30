function fig = ScaleFigure(fig, magnitude)
%% MScheller 04.11.20. scale a figure up proportionally for better screen visibilty when working with publishable figures

if nargin == 0
    fig = gcf;
    magnitude = 2;
end

if nargin == 1
    magnitude = 2; % default scale factor
end

fig.Units = 'centimeters';
fig.Position = [fig.Position(1:2) fig.Position(3:4).*magnitude];

objects = fig.Children;
for ox=1:length(objects)
    if ~strcmp(objects(ox).Type,'tiledlayout')&&~strcmp(objects(ox).Type,'subplottext')
        objects(ox).Units = 'centimeters';
        objects(ox).Position = objects(ox).Position.*magnitude;
    end
end

