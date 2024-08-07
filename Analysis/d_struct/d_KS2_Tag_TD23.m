for ux = 1:length(d_KS2.clust_params)
    %if ~isempty(d_KS2.laser{1}{1}) %OptRed channel
    if ~isempty(d_KS2.laser{1,d_KS2.map(ux)}{1,1})
        [d_KS2.clust_params(ux).crosstagVS, d_KS2.clust_params(ux).taginfo,~] = CrossTagTD23(d_KS2,ux,0); %crosstag=1(excited);crosstag=2(inhibited);crosstag=3(biphasic) %Taginfo serves to plot tag correlogram
%                 TagDir = [output filesep 'tag_plots' filesep dlist(dx).name(1:10) filesep];
%                 if ~isfolder(TagDir)
%                 mkdir(TagDir)
%                 end
%                 if ~isempty(fh)
%                     saveas(fh,[TagDir d.clust_params(ux).session '_unit' num2str(ux) '.png'])
%                     close(fh)
%                 end

        [d_KS2.clust_params(ux).tag_lat] = load_taglat_TD23(d_KS2,ux); %latency for highest bin in tagged unit

        dataset = 'KS2';
        d_KS2.clust_params(ux).([d_KS2.clust_params(ux).genotype '_tagged']) = tag_eval_TD23(d_KS2,ux,dataset);
    end
end