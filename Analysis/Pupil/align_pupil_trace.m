%% Add aligned_trace to d.pupil based on the camera-intan time difference
%20240402 AZ: still lack camera timestamps from delay silence and excite sessions 

clearvars -except d

% load('\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD23\D-struct\KS3\d_02-Apr-2024.mat');

% session_index = find(~cellfun(@isempty, {d.pupil.raw_trace},'UniformOutput',1));
session_index = find(~cellfun(@isempty, {d.info.LED_on_trigger_camera},'UniformOutput',1));

for ses = 1:numel(session_index)
    sid = session_index(ses);
    
    if d.info(sid).LED_on_trigger_intan - d.info(sid).LED_on_trigger_camera > 0
        Intan_Video_TimeDiff = d.info(sid).LED_on_trigger_intan - d.info(sid).LED_on_trigger_camera;
        Intan_Video_FrameDiff = round(Intan_Video_TimeDiff.*10); %10 fr/s
        % add nans to beginning of video to align to intan
        d.pupil(sid).aligned_trace = cat(1, NaN(Intan_Video_FrameDiff,1), d.pupil(sid).raw_trace);
    end
    
    if d.info(sid).LED_on_trigger_intan - d.info(sid).LED_on_trigger_camera < 0
        Intan_Video_TimeDiff = d.info(sid).LED_on_trigger_camera - d.info(sid).LED_on_trigger_intan;
        Intan_Video_FrameDiff = round(Intan_Video_TimeDiff.*10); %10 fr/s
        %Remove the additional video frames to match with intan frames
        d.pupil(sid).aligned_trace = d.pupil(sid).raw_trace((Intan_Video_FrameDiff+1):end);
    end
        
end

save("/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/d_23-May-2024.mat", 'd','-v7.3')
% save('\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD23\D-struct\KS3\d_02-Apr-2024.mat','d','-v7.3');
