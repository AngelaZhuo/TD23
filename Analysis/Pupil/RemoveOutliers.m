%% Remove extreme outliers from CleanPupil_2024.m
% After running the pupil trace through CleanPupil_2024 the first time, some plots show extreme outliers that would 
% significantly skew the STD for the whole trace. Therefore, these outliers need to be removed from the raw data then
% rerun the modified raw data through CleanPupil_2024

%Load the Namer and Pupil matrix

%Make a matrix with sessions x 2 size, one column is upper limit and the other is lower limit 

Limits = [];
Limits(8,1) = 390; Limits(16,1)=300; Limits(59,2)=120; Limits(66,2)=100; Limits(74,1)=350; Limits(84,2)=100;
Limits(94,2)=100; Limits(164,1)=300; Limits(174,2)=50; Limits(184,2)=30; Limits(214,2)=30; Limits(343,1)=190;
Limits(359,1)=200; Limits(362,1)=200; Limits(362,2)=80; Limits(379,2)=40; Limits(386,1)=230; Limits(395,1)=200; Limits(395,2)=100;
Limits(396:404,1)=0;Limits(396:404)=0;

for pup = 1:size(Pupil,1)
   current = Pupil(pup,:,:);
   if Limits(pup,1)>0
       current(current>Limits(pup,1))=NaN;
   end
   
   if Limits(pup,2)>0
       current(current<Limits(pup,2))=NaN;
   end
   Pupil(pup,:,:)=current;
end

save("/zi-flstorage/data/Angela/DATA/TD23/Matrices/Pupil_pre-clean.mat", "Pupil", "TM", "Events","Namer","Pump")
