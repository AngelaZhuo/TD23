%% check expermiental vectors used

clearvars -except d

for rt = 1:size(d.pupil,2)
    sids(rt) = ~isempty(d.pupil(rt).raw_trace);
end
sids = find(sids == 1);
sids=sids(:,3:end);

TMs = NaN(numel(sids),150);

for sx = 1:numel(sids)
    try
    TMs(sx,:) = [d.events{sids(sx)}.curr_trialtype];
    catch
    warning('the d.events(%s) is empty',num2str(sids(sx)))
    end
end

%%

[usedVec,~,usedVecNum] = unique(TMs,'rows');

 

animals = ["y0" + string(1:9),"y10", "y1"+ string(1:9),"y20"];

AnVecMat = NaN(20,max([d.info.tag_ncount]));

for ax = 1:20

    anSids = find(strcmp({d.info(sids).animal},animals(ax)));
    
    for ansx = 1:numel(anSids)
        AnVecMat(ax,[d.info(sids(anSids(ansx))).tag_ncount]) = usedVecNum(anSids(ansx));
    end

end

%%

clf

plot(AnVecMat(1:2:end,:)','LineWidth',2)%,'.','MarkerSize',15)

hold on

plot(AnVecMat(2:2:end,:)'+.5,'LineWidth',2)%,'.','MarkerSize',15)

%%

legend([animals(1:2:end), animals(2:2:end)])

title 'used experimental vector'

ylabel('VecNum')

xlabel('session')