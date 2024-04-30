function [parent, orgchild] = CombineFigures(parent, orgchild, position, scaling)
%% MScheller 12.03.21 integrate one figure ('child'-handle) into another ('parent'-handle) with the lower left corner offset by position ([vertical, horizontal] in cm)
% keyboard

child = copyobj(orgchild, 0);

if exist('scaling')
ScaleFigure(child, scaling);
end

if ~exist('position')
   position = [0 0]; 
end

ExtendFigure(child, 'left', position(2));
ExtendFigure(child, 'bottom', position(1));
drawnow;%pause(0.01);
copyobj(child.Children, parent);

close(child);
clear child;