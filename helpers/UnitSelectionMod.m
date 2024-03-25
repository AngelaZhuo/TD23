%% Script for unit selection using modular select strings
%% MA 240129
%% obligatory input
% % - d: datastruct
% % - slctstr: modular string for unit selection, modules begin with
% %            uppercase letters
%% optional input
% % - uids: unit IDs in case we need a subselection of a selection of units
% % - sids: session IDs in case we need a unit selection of specific
% %         sessions, not for range of session count, as this would be
% %         integrated in the string
% % output
% % - ulog: logical column vector with length equal to number of units
% %         in d OR length of uids
%%
function ulog = UnitSelectionMod(d,slctstr,uids,sids)

ulog = true(numel(d.spikes),1);
ulog(neverUseTheseUnits(d)) = false;

mods = split(regexprep(slctstr, '([A-Z])', ' $1'));
mods(cellfun(@isempty,mods))=[];


if exist('sids','var')
    ulog(~ismember(d.map,sids)) = false;
end

if ~isfield(d.clust_params,'antshift')
    d.clust_params(1).antshift = [];
    [d.clust_params.antshift] = deal(0);
end

for mx = 1:numel(mods)
    switch mods{mx}
        case 'Ant'
            ulog([d.clust_params.antshift]~=1) = false;
        case 'Post'
            ulog([d.clust_params.antshift]~=0) = false;
        case 'Med'
            ulog([d.clust_params.medlat]~=1) = false;
        case 'Lat'
            ulog([d.clust_params.medlat]~=2) = false;
            
            %regions
        case 'Nac'
            ulog([d.clust_params.region_coding]~=1) = false;
        case 'Tu'
            ulog([d.clust_params.region_coding]~=2) = false;
        case 'Vta'
            ulog([d.clust_params.region_coding]~=3|[d.clust_params.antshift]==1) = false;
            
            %cell types
        case 'Pmsn'
            ulog([d.clust_params.mean_fr]<=.25|[d.clust_params.mean_fr]>=5|...
                ~ismember([d.clust_params.region_coding],[1 2])) = false;
        case 'Pdan'
            ulog([d.clust_params.mean_fr]<=1|[d.clust_params.mean_fr]>=12| ...
                [d.clust_params.region_coding]~=3|[d.clust_params.antshift]==1|...
                ~([d.clust_params.funcDAN_odorcue]|[d.clust_params.funcDAN_rewardcue]|[d.clust_params.funcDAN_reward])) = false;
        case 'Pdannofunc'
            ulog([d.clust_params.mean_fr]<=1|[d.clust_params.mean_fr]>=12| ...
                [d.clust_params.region_coding]~=3|[d.clust_params.antshift]==1|...
                ([d.clust_params.funcDAN_odorcue]|[d.clust_params.funcDAN_rewardcue]|[d.clust_params.funcDAN_reward])) = false;

            
            %tagging
        case 'Tagd1'
            try
                ulog([d.clust_params.mean_fr]<=.25|[d.clust_params.mean_fr]>=5|...
                ~ismember([d.clust_params.region_coding],[1 2])|...
                [d.clust_params.D1_tagged]~=1) = false;
            catch
                ulog([d.clust_params.mean_fr]<=.25|[d.clust_params.mean_fr]>=5|...
                ~ismember([d.clust_params.region_coding],[1 2])|...
                [d.clust_params.d1_tagged]~=1) = false;
            end          
        case 'Tagd2'
            ulog([d.clust_params.mean_fr]<=.25|[d.clust_params.mean_fr]>=5|...
                ~ismember([d.clust_params.region_coding],[1 2])|...
                [d.clust_params.D2_tagged]~=1) = false;  
        case 'Tagdat'
            ulog([d.clust_params.mean_fr]<=1|[d.clust_params.mean_fr]>=12|...
                [d.clust_params.region_coding]~=3|[d.clust_params.antshift]==1|...
                ~([d.clust_params.funcDAN_odorcue]|[d.clust_params.funcDAN_rewardcue]|[d.clust_params.funcDAN_reward])|...
                [d.clust_params.DAT_tagged]~=1) = false;
        case 'Notd2'
            % get units recorded on same tetrodes and in same sessions as tagged D2 MSN            
            ulogTagd2 = [d.clust_params.mean_fr]>.25&[d.clust_params.mean_fr]<5&...
                ismember([d.clust_params.region_coding],[1 2])&...
                [d.clust_params.D2_tagged]==1;

            sxTagd2 = d.map(ulogTagd2);
            try txTagd2 = [d.clust_params(ulogTagd2).tetrode];catch; txTagd2 = [d.clust_params(ulogTagd2).trode];end
                        
            sx = d.map;
            try tx = [d.clust_params.tetrode];catch; tx = [d.clust_params.trode];end
            
            ulog(~ismember([sx;tx]',[sxTagd2;txTagd2]','rows')|ulogTagd2') = false;
            

            
        otherwise
            % select by tetrode
            if contains(mods{mx},'Tx(')
                paropen = strfind(mods{mx},'(');
                parclose = strfind(mods{mx},')');
                txrg = strsplit(mods{mx}(paropen+1:parclose-1),':');
                if numel(txrg)==1; txrg = [txrg txrg]; end
                try 
                    tidrg = find([d.clust_params.tetrode]>=str2double(txrg{1})&[d.clust_params.tetrode]<=str2double(txrg{2}));
                catch
                    tidrg = find([d.clust_params.tetrode]>=str2double(txrg{1})&[d.clust_params.tetrode]<=str2double(txrg{2}));
                end
                ulog(~ismember(1:numel(d.clust_params),tidrg)) = false;
                
            % select by experiment
            elseif contains(mods{mx},'X(')
                paropen = strfind(mods{mx},'(');
                parclose = strfind(mods{mx},')');
                xcur = mods{mx}(paropen+1:parclose-1);
                switch xcur
                    % TD19
                    case 'td19'
                        xIdx = find(contains({d.info.tag},'TD19_EPhys'));
                        ulog(~ismember(d.map,xIdx)) = false;
                    % TD23
                    case 'pmc'
                        xIdx = find(contains({d.info.tag},'PMC'));
                        ulog(~ismember(d.map,xIdx)) = false;
                    case 'sham'
                        xIdx = find(contains({d.info.tag},'sham','IgnoreCase',true));
                        ulog(~ismember(d.map,xIdx)) = false;
                    case 'silence'
                        xIdx = find(contains({d.info.tag},'silence','IgnoreCase',true));
                        ulog(~ismember(d.map,xIdx)) = false;
                    case 'excite'
                        xIdx = find(contains({d.info.tag},'excite','IgnoreCase',true));
                        ulog(~ismember(d.map,xIdx)) = false;    
                    case 'cs1_silence'
                        xIdx = find(strcmp({d.info.tag},'CS1_silence'));
                        ulog(~ismember(d.map,xIdx)) = false;
                    case 'cs1_silence_sham'
                        xIdx = find(strcmp({d.info.tag},'CS1_silence_sham'));
                        ulog(~ismember(d.map,xIdx)) = false;                        
                    case 'cs1delay_silence'
                        xIdx = find(strcmp({d.info.tag},'CS1delay_silence'));
                        ulog(~ismember(d.map,xIdx)) = false;
                    case 'cs1delay_silence_sham'
                        xIdx = find(strcmp({d.info.tag},'CS1delay_silence_sham'));
                        ulog(~ismember(d.map,xIdx)) = false;                        
                    case 'cs2_silence'
                        xIdx = find(strcmp({d.info.tag},'CS2_silence'));
                        ulog(~ismember(d.map,xIdx)) = false;
                    case 'cs2_silence_sham'
                        xIdx = find(strcmp({d.info.tag},'CS2_silence_sham'));
                        ulog(~ismember(d.map,xIdx)) = false;                                                
                    case 'cs2delay_silence'
                        xIdx = find(strcmp({d.info.tag},'CS2delay_silence'));
                        ulog(~ismember(d.map,xIdx)) = false;                        
                    case 'cs2delay_silence_sham'
                        xIdx = find(strcmp({d.info.tag},'CS2delay_silence_sham'));
                        ulog(~ismember(d.map,xIdx)) = false;                         
                    case 'excitea'
                        xIdx = find(strcmp({d.info.tag},'exciteA'));
                        ulog(~ismember(d.map,xIdx)) = false;                                
                    case 'excitea_sham'
                        xIdx = find(strcmp({d.info.tag},'exciteA_sham'));
                        ulog(~ismember(d.map,xIdx)) = false;                                     
                    case 'exciteb'
                        xIdx = find(strcmp({d.info.tag},'exciteB'));
                        ulog(~ismember(d.map,xIdx)) = false;                                
                    case 'exciteb_sham'
                        xIdx = find(strcmp({d.info.tag},'exciteB_sham'));
                        ulog(~ismember(d.map,xIdx)) = false;                                     
                    otherwise
                        error('Paradigm does not exist!')
                        
                end
            %sessioncount    
            elseif contains(mods{mx},'Sct(')
                paropen = strfind(mods{mx},'(');
                parclose = strfind(mods{mx},')');
                sctrg = strsplit(mods{mx}(paropen+1:parclose-1),':');
                if numel(sctrg)==1; sctrg = [sctrg sctrg]; end
                try 
                    sidrg = find([d.info.session_count]>=str2double(sctrg{1})&[d.info.session_count]<=str2double(sctrg{2}));
                catch
                    sidrg = find([d.info.tag_ncount]>=str2double(sctrg{1})&[d.info.tag_ncount]<=str2double(sctrg{2}));
                end
                ulog(~ismember(d.map,sidrg)) = false;
            %sessioncount counting each recording as full session
            elseif contains(mods{mx},'Sctrec(')
                error('Not yet implempented')
                paropen = strfind(mods{mx},'(');
                parclose = strfind(mods{mx},')');
                %only include specific animals
            elseif contains(mods{mx},{'Animals(','Animal('})
                paropen = strfind(mods{mx},'(');
                parclose = strfind(mods{mx},')');
                animals = strsplit(mods{mx}(paropen+1:parclose-1),',');
                ulog(~ismember({d.clust_params.animal},animals)) = false;
                %exclude animals
            elseif contains(mods{mx},{'Notanimals(','Notanimal('})
                paropen = strfind(mods{mx},'(');
                parclose = strfind(mods{mx},')');
                animals = strsplit(mods{mx}(paropen+1:parclose-1),',');
                ulog(ismember({d.clust_params.animal},animals)) = false;
                % string not matching any case or if statement
            else
                error(['Select string - ' mods{mx} ' - is wrong.'])
            end
    end
end
if exist('uids','var')
    ulog = ulog(uids);
end
end

%% subfunction
function u2x = neverUseTheseUnits(d)
u2x = ([d.clust_params.region_coding]==99|... % -> units on tetrodes located outside of any region of interest
    [d.clust_params.mean_fr]<.25); % -> mostly artifacts and trash
end
