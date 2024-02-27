function setDeskTitleCmdColor(Ttl,Clr)

%% input:

% - Ttl: title string

% - Clr: integer (currently 1-6)

 

%% set title

mainFrame = com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame;

currTitle = string(mainFrame.getTitle);

strsplit(currTitle, "     ////     ");

mainFrame.setTitle(ans(1) + "     ////     " + string(Ttl))

 

%% Change color of the command window

% color options

Clrs = [.99 .8 .8;...

.8 .99 .8;...

.8 .8 .99;...

.99 .99 .8;...

.99 .8 .99;...

.8 .99 .99];

 

cmdWinDoc = com.mathworks.mde.cmdwin.CmdWinDocument.getInstance;

listeners = cmdWinDoc.getDocumentListeners;

jTextArea = listeners(5);  % 4 & 5

jTextArea.setBackground(java.awt.Color(Clrs(Clr,1), Clrs(Clr,2), Clrs(Clr,3)));

