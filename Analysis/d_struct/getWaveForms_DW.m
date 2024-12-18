%% Modified waveform loading by Lennart and David, originally also from spikes toolbox
function wf = getWaveForms_DW(gwfparams)
% function wf = getWaveForms(gwfparams)
%
% Extracts individual spike waveforms from the raw datafile, for multiple
% clusters. Returns the waveforms and their means within clusters.
%
% Contributed by C. Schoonover and A. Fink
%
% % EXAMPLE INPUT
% gwfparams.dataDir = '/path/to/data/';    % KiloSort/Phy output folder
% gwfparams.fileName = 'data.dat';         % .dat file containing the raw 
% gwfparams.dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
% gwfparams.nCh = 32;                      % Number of channels that were streamed to disk in .dat file
% gwfparams.wfWin = [-40 41];              % Number of samples before and after spiketime to include in waveform
% gwfparams.nWf = 2000;                    % Number of waveforms per unit to pull out
% gwfparams.spikeTimes =    [2,3,5,7,8,9]; % Vector of cluster spike times (in samples) same length as .spikeClusters
% gwfparams.spikeClusters = [1,2,1,1,1,2]; % Vector of cluster IDs (Phy nomenclature)   same length as .spikeTimes
%
% % OUTPUT
% wf.unitIDs                               % [nClu,1]            List of cluster IDs; defines order used in all wf.* variables
% wf.spikeTimeKeeps                        % [nClu,nWf]          Which spike times were used for the waveforms
% wf.waveForms                             % [nClu,nWf,nCh,nSWf] Individual waveforms
% wf.waveFormsMean                         % [nClu,nCh,nSWf]     Average of all waveforms (per channel)
%                                          % nClu: number of different clusters in .spikeClusters
%                                          % nSWf: number of samples per waveform
%
% % USAGE
% wf = getWaveForms(gwfparams);

% Load .dat and KiloSort/Phy output
% fileName = fullfile(gwfparams.dataDir,gwfparams.fileName); %For OFC-AI cohort 
fileName = gwfparams.fileName;
filenamestruct = dir(fileName);
dataTypeNBytes = numel(typecast(cast(0, gwfparams.dataType), 'uint8')); % determine number of bytes per sample
nSamp = filenamestruct.bytes/(gwfparams.nCh*dataTypeNBytes);  % Number of samples per channel
wfNSamples = length(gwfparams.wfWin(1):gwfparams.wfWin(end));
mmf = memmapfile(fileName, 'Format', {gwfparams.dataType, [gwfparams.nCh nSamp], 'x'});
chMap = readNPY(fullfile(gwfparams.curationDir, 'channel_map.npy'))+1;               % Order in which data was streamed to disk; must be 1-indexed for Matlab
nChInMap = numel(chMap);

% Read spike time-centered waveforms
% unitIDs = unique(gwfparams.spikeClusters);

% added filtering DW:
LowPass = 5000;
HighPass = 300;
[c,d] = butter(4, [HighPass LowPass]/(30000/2));


unitIDs = gwfparams.cids(gwfparams.cgs==2); % | gwfparams.cgs==1); %change LO/DW
numUnits = size(unitIDs,2);
spikeTimeKeeps = nan(numUnits,gwfparams.nWf);
waveForms = nan(numUnits,gwfparams.nWf,nChInMap,wfNSamples);
waveFormsMean = nan(numUnits,nChInMap,wfNSamples);
waveFormsMedian = nan(numUnits,nChInMap,wfNSamples);
%DW:
% waveForms_flt = nan(numUnits,gwfparams.nWf,nChInMap,wfNSamples);
% waveFormsMean_flt = nan(numUnits,nChInMap,wfNSamples);
% waveFormsMedian_flt = nan(numUnits,nChInMap,wfNSamples);

for curUnitInd=1:numUnits
    curUnitID = unitIDs(curUnitInd);
    curSpikeTimes = gwfparams.spikeTimes(gwfparams.spikeClusters==curUnitID);
    curUnitnSpikes = size(curSpikeTimes,1);
    spikeTimesRP = curSpikeTimes(randperm(curUnitnSpikes));
    
    % DW: exclude spitimes too close to the end of the recording
    spikeTimesRP(spikeTimesRP > (size(mmf.Data.x,2)-50)) = [];
    
%     spikeTimeKeeps(curUnitInd,1:min([gwfparams.nWf curUnitnSpikes])) = sort(spikeTimesRP(1:min([gwfparams.nWf curUnitnSpikes])));
    spikeTimeKeeps(curUnitInd,1:min([gwfparams.nWf size(spikeTimesRP,1)])) = int32(sort(spikeTimesRP(1:min([gwfparams.nWf size(spikeTimesRP,1)])))); %change LO
    for curSpikeTime = 1:min([gwfparams.nWf size(spikeTimesRP,1)])
        tmpWf = mmf.Data.x(1:gwfparams.nCh,spikeTimeKeeps(curUnitInd,curSpikeTime)+gwfparams.wfWin(1):spikeTimeKeeps(curUnitInd,curSpikeTime)+gwfparams.wfWin(end));
        tmpWF_flt = int16(filtfilt(c,d, double(tmpWf)')'); %DW
        waveForms(curUnitInd,curSpikeTime,:,:) = tmpWf(chMap,:);
        waveForms_flt(curUnitInd,curSpikeTime,:,:) = tmpWF_flt(chMap,:); %DW
    end
    waveFormsMean(curUnitInd,:,:) = squeeze(nanmean(waveForms(curUnitInd,:,:,:)));
    waveFormsMedian(curUnitInd,:,:) = squeeze(nanmedian(waveForms(curUnitInd,:,:,:)));
    
    waveFormsMean_flt(curUnitInd,:,:) = squeeze(nanmean(waveForms_flt(curUnitInd,:,:,:)));
    waveFormsMedian_flt(curUnitInd,:,:) = squeeze(nanmedian(waveForms_flt(curUnitInd,:,:,:)));
    disp(['Completed ' int2str(curUnitInd) ' units of ' int2str(numUnits) '.']);
end

% Package in wf struct
wf.unitIDs = unitIDs;
wf.spikeTimeKeeps = spikeTimeKeeps;
% wf.waveForms = waveForms;
wf.waveFormsMean = waveFormsMean;
wf.waveFormsMedian = waveFormsMedian;
% wf.waveForms_flt = waveForms_flt;
wf.waveFormsMean_flt = waveFormsMean_flt;
wf.waveFormsMedian_flt = waveFormsMedian_flt;

end

% function wf = getWaveForms_filtered_DW(gwfparams)
% % function wf = getWaveForms(gwfparams)
% %
% % Extracts individual spike waveforms from the raw datafile, for multiple
% % clusters. Returns the waveforms and their means within clusters.
% %
% % Contributed by C. Schoonover and A. Fink
% %
% % % EXAMPLE INPUT
% % gwfparams.dataDir = '/path/to/data/';    % KiloSort/Phy output folder
% % gwfparams.fileName = 'data.dat';         % .dat file containing the raw 
% % gwfparams.dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
% % gwfparams.nCh = 32;                      % Number of channels that were streamed to disk in .dat file
% % gwfparams.wfWin = [-40 41];              % Number of samples before and after spiketime to include in waveform
% % gwfparams.nWf = 2000;                    % Number of waveforms per unit to pull out
% % gwfparams.spikeTimes =    [2,3,5,7,8,9]; % Vector of cluster spike times (in samples) same length as .spikeClusters
% % gwfparams.spikeClusters = [1,2,1,1,1,2]; % Vector of cluster IDs (Phy nomenclature)   same length as .spikeTimes
% %
% % % OUTPUT
% % wf.unitIDs                               % [nClu,1]            List of cluster IDs; defines order used in all wf.* variables
% % wf.spikeTimeKeeps                        % [nClu,nWf]          Which spike times were used for the waveforms
% % wf.waveForms                             % [nClu,nWf,nCh,nSWf] Individual waveforms
% % wf.waveFormsMean                         % [nClu,nCh,nSWf]     Average of all waveforms (per channel)
% %                                          % nClu: number of different clusters in .spikeClusters
% %                                          % nSWf: number of samples per waveform
% %
% % % USAGE
% % wf = getWaveForms(gwfparams);
% 
% % Load .dat and KiloSort/Phy output
% fileName = fullfile(gwfparams.dataDir,gwfparams.fileName);             
% filenamestruct = dir(fileName);
% dataTypeNBytes = numel(typecast(cast(0, gwfparams.dataType), 'uint8')); % determine number of bytes per sample
% nSamp = filenamestruct.bytes/(gwfparams.nCh*dataTypeNBytes);  % Number of samples per channel
% wfNSamples = length(gwfparams.wfWin(1):gwfparams.wfWin(end));
% mmf = memmapfile(fileName, 'Format', {gwfparams.dataType, [gwfparams.nCh nSamp], 'x'});
% chMap = readNPY(fullfile(gwfparams.dataDir, 'channel_map.npy'))+1;               % Order in which data was streamed to disk; must be 1-indexed for Matlab
% nChInMap = numel(chMap);
% 
% % Read spike time-centered waveforms
% % unitIDs = unique(gwfparams.spikeClusters);
% 
% % added filtering DW:
% LowPass = 5000;
% HighPass = 300;
% [c,d] = butter(4, [HighPass LowPass]/(30000/2));
% 
% 
% unitIDs = gwfparams.cids(gwfparams.cgs==2); % | gwfparams.cgs==1); %change LO/DW
% numUnits = size(unitIDs,2);
% spikeTimeKeeps = nan(numUnits,gwfparams.nWf);
% % waveForms = nan(numUnits,gwfparams.nWf,nChInMap,wfNSamples);
% % waveFormsMean = nan(numUnits,nChInMap,wfNSamples);
% % waveFormsMedian = nan(numUnits,nChInMap,wfNSamples);
% %DW:
% waveForms_flt = nan(numUnits,gwfparams.nWf,nChInMap,wfNSamples);
% waveFormsMean_flt = nan(numUnits,nChInMap,wfNSamples);
% waveFormsMedian_flt = nan(numUnits,nChInMap,wfNSamples);
% 
% for curUnitInd=1:numUnits
%     curUnitID = unitIDs(curUnitInd);
%     curSpikeTimes = gwfparams.spikeTimes(gwfparams.spikeClusters==curUnitID);
%     curUnitnSpikes = size(curSpikeTimes,1);
%     spikeTimesRP = curSpikeTimes(randperm(curUnitnSpikes));
%     
%      % DW: exclude spitimes too close to the end of the recording
%     spikeTimesRP(spikeTimesRP > (size(mmf.Data.x,2)-50)) = [];
%     
% %     spikeTimeKeeps(curUnitInd,1:min([gwfparams.nWf curUnitnSpikes])) = sort(spikeTimesRP(1:min([gwfparams.nWf curUnitnSpikes])));
%     spikeTimeKeeps(curUnitInd,1:min([gwfparams.nWf size(spikeTimesRP,1)])) = int32(sort(spikeTimesRP(1:min([gwfparams.nWf size(spikeTimesRP,1)])))); %change LO
%     for curSpikeTime = 1:min([gwfparams.nWf size(spikeTimesRP,1)])
%         tmpWf = mmf.Data.x(1:gwfparams.nCh,spikeTimeKeeps(curUnitInd,curSpikeTime)+gwfparams.wfWin(1):spikeTimeKeeps(curUnitInd,curSpikeTime)+gwfparams.wfWin(end));
%         tmpWF_flt = int16(filtfilt(c,d, double(tmpWf)')'); %DW
% %         waveForms(curUnitInd,curSpikeTime,:,:) = tmpWf(chMap,:);
%         waveForms_flt(curUnitInd,curSpikeTime,:,:) = tmpWF_flt(chMap,:); %DW
%     end
% %     waveFormsMean(curUnitInd,:,:) = squeeze(nanmean(waveForms(curUnitInd,:,:,:)));
% %     waveFormsMedian(curUnitInd,:,:) = squeeze(nanmedian(waveForms(curUnitInd,:,:,:)));
%     
%     waveFormsMean_flt(curUnitInd,:,:) = squeeze(nanmean(waveForms_flt(curUnitInd,:,:,:)));
%     waveFormsMedian_flt(curUnitInd,:,:) = squeeze(nanmedian(waveForms_flt(curUnitInd,:,:,:)));
%     disp(['Completed ' int2str(curUnitInd) ' units of ' int2str(numUnits) '.']);
% end
% 
% % Package in wf struct
% wf.unitIDs = unitIDs;
% wf.spikeTimeKeeps = spikeTimeKeeps;
% % wf.waveForms = waveForms;
% % wf.waveFormsMean = waveFormsMean;
% % wf.waveFormsMedian = waveFormsMedian;
% % wf.waveForms_flt = waveForms_flt;
% wf.waveFormsMean_flt = waveFormsMean_flt;
% wf.waveFormsMedian_flt = waveFormsMedian_flt;
% 
% end


function fileList = getAllFiles(dirName, fileExtension, appendFullPath)

  dirData = dir([dirName '/' fileExtension]);      %# Get the data for the current directory
  dirWithSubFolders = dir(dirName);
  dirIndex = [dirWithSubFolders.isdir];  %# Find the index for directories
  fileList = {dirData.name}';  %'# Get a list of the files
  if ~isempty(fileList)
    if appendFullPath
      fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
    end
  end
  subDirs = {dirWithSubFolders(dirIndex).name};  %# Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
  for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir, fileExtension, appendFullPath)];  %# Recursively call getAllFiles
  end

end
