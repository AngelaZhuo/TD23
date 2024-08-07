

regions = {'NAcc' 'OT' 'VTA'};

for ux = 1:numel([d_KS2.clust_params.unit_nr])
    
    curr_tetrode = d_KS2.clust_params(ux).trode;
    
    animal = d_KS2.clust_params(ux).animal;
    
    chan_map = ChannelMapAZ.(animal);
    
  
    if chan_map.region(curr_tetrode) == 99

       d_KS2.clust_params(ux).region = 'Region99';
       
       d_KS2.clust_params(ux).region_coding = chan_map.region(curr_tetrode);
       
    else

    d_KS2.clust_params(ux).region    = regions{chan_map.region(curr_tetrode)};

    d.KS2.clust_params(ux).region_coding    = chan_map.region(curr_tetrode);
    end
end