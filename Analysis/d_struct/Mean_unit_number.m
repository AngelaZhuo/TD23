%% Get the mean unit number from the d_KS2


%Mean number of pMSNs per animal-day session
VS_index = ([d_KS2.clust_params.region_coding] == 1) | ([d_KS2.clust_params.region_coding] == 2);
VS_units = d_KS2.clust_params(VS_index);
VS_pMSN = VS_units([VS_units.mean_fr]<5 & [VS_units.mean_fr]>.25 & [VS_units.ref_viols]<2);
mean_pMSN = numel(VS_pMSN)/numel(unique({d_KS2.clust_params.session}));

%Mean number of pDANs per animal-day session
VTA_units = d_KS2.clust_params([d_KS2.clust_params.region_coding]==3);
VTA_pDAN = VTA_units([VTA_units.mean_fr]<12 & [VTA_units.mean_fr]>1 & [VTA_units.antshift] == 0 & [VTA_units.ref_viols]<2);
mean_pDAN = numel(VTA_pDAN)/numel(unique({d_KS2.clust_params.session}));

%Mean number of units per animal-day session
mean_units = numel(d_KS2.clust_params)/numel(unique({d_KS2.clust_params.session}));


%% Get the mean unit number of the same sessions from KS3 d-struct

session_id = unique({d_KS2.clust_params.session});

soi = d.clust_params(ismember({d.clust_params.session},session_id));

KS3_mean_units = numel(soi)/numel(session_id);

%Mean number of pMSNs per animal-day session
KS3_VS_index = ([d.clust_params.region_coding] == 1) | ([d.clust_params.region_coding] == 2);
KS3_VS_units = d.clust_params(KS3_VS_index);
KS3_VS_pMSN = KS3_VS_units([KS3_VS_units.mean_fr]<5 & [KS3_VS_units.mean_fr]>.25 & [KS3_VS_units.ref_violations]<.02);
KS3_mean_pMSN = numel(KS3_VS_pMSN)/numel(unique({d.clust_params.session}));

%Mean number of pDANs per animal-day session
KS3_VTA_units = d.clust_params([d.clust_params.region_coding]==3);
KS3_VTA_pDAN = KS3_VTA_units([KS3_VTA_units.mean_fr]<12 & [KS3_VTA_units.mean_fr]>1 & [KS3_VTA_units.antshift] == 0 & [KS3_VTA_units.ref_violations]<.02);
KS3_mean_pDAN = numel(KS3_VTA_pDAN)/numel(unique({d.clust_params.session}));

%Get number of KS3 D1-tagged units
KS3_tagged_units = d.clust_params([d.clust_params.d1_tagged] ==1 & KS3_VS_index);
KS3_tagged_units_sham = KS3_tagged_units(contains({KS3_tagged_units.tag},'sham'));



