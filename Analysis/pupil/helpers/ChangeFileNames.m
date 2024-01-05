function ChangeFileNames
ses_path = '\\zisvfs12\Home\yi.zhuo\Documents\GitHub\TD22\Analysis\Pupil\Master_GLM\Sessions';
%     "\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\DeepLabCut\PMC_8point_coord\20220823_TD22"...
%     "\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\DeepLabCut\PMC_8point_coord\20220824_TD22"];
All_ses = getAllFiles(ses_path,'*.mat',1);
for sx = 1:numel(All_ses)
   currSesPth =  All_ses{sx};
   currSesPthNew = strrep(currSesPth,'thr0.99_','');
   if ~strcmp(currSesPth,currSesPthNew)
       movefile(currSesPth,currSesPthNew)
   end
end