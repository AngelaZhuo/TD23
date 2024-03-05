%% Script for unit selection using modular select strings
%% MA 240129
% % input
% % - d: datastruct
% % - slctstr: modular string for unit selection, modules begin with
% %            uppercase letters
% % - uids: unit IDs in case we need a subselection of a selection of units
% % - sids: session IDs in case we need a unit selection of specific
% %         sessions, not for range of session count, as this would be
% %         integrated in the string
% % output
% % - ulog: column vector of logicals with length equal to number of units
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
            
            %tagging
        case 'Tagd1'
            ulog([d.clust_params.mean_fr]<=.25|[d.clust_params.mean_fr]>=5|...
                ~ismember([d.clust_params.region_coding],[1 2])|...
                [d.clust_params.D1_tagged]~=1) = false;            
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
            %sessioncount
            if contains(mods{mx},'Sct(')
                paropen = strfind(mods{mx},'(');
                parclose = strfind(mods{mx},')');
                sctrg = strsplit(mods{mx}(paropen+1:parclose-1),':');
                try    sidrg = find([d.info.session_count]>=str2double(sctrg{1})&[d.info.session_count]<=str2double(sctrg{2}));
                catch; sidrg = find([d.info.tag_ncount]>=str2double(sctrg{1})&[d.info.tag_ncount]<=str2double(sctrg{2})); end    
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
            end
    end
end
if exist('uids','var')
    ulog = ulog(uids);
end