function fig = ExtendFigure(fig, direction, magnitude)
%% MScheller 07102020. Helper function for figure formatting: adds white space for further plots
%
if nargin == 2
    magnitude = 3.5; % default extension
end

fig.Units = 'centimeters';
switch direction
    case {'left', 'right', 'horizontal'}
        fig.Position = fig.Position+[0 0 magnitude 0];
    case {'above', 'below', 'vertical', 'top', 'bottom'}
        fig.Position = fig.Position+[0 0 0 magnitude];
    case {'everywhere', 'all', 'all directions'}
        fig.Position = fig.Position+[0 0 magnitude magnitude];
end

switch direction
    case 'left'
        shift = [magnitude 0 0 0];
    case 'horizontal'
        shift = [magnitude/2 0 0 0];
    case 'right'
        shift = [0 0 0 0];
    case {'above', 'top'}
        shift = [0 0 0 0];
    case {'below', 'bottom'}
        shift = [0 magnitude 0 0 ];
    case 'vertical'
        shift = [0 magnitude/2 0 0];
    case {'all', 'everywhere', 'all directions'}
        shift = [magnitude/2 magnitude/2 0 0];
end

objects = fig.Children;

for ox=1:length(objects)
    if ~strcmp(objects(ox).Type,'subplottext')
    objects(ox).Units = 'centimeters';
    objects(ox).Position = objects(ox).Position+shift;
    end
end

