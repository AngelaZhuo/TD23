function f = plot_P3_popVec_trajectory_TD23(d,unit_maps, ops)
%% plots population vector trajectories over time and orthogonalizes for social vs. non-social odors
% build spike count population vector
% Modified from plot_P3_popVec_trajectory.m (DW)
[pop_vec,ops] = build_PopVec(d,unit_maps,ops);
lineProps.col = get_colors(2);
lineProps.width = 1;
clear population averaged_population xe X mappedX
population = cellfun(@(x) permute(x,[3 1 2]), pop_vec, 'UniformOutput', false);%cell for every conditions: trials x units x time
% average population across trials -> cell: units x time
for ph=1:size(population,2)
    % averaged_population{ph}(:,:)=mean(population{ph}(fvOn_bin_position:end,:,:),1);
    averaged_population{ph}(:,:)=mean(population{ph}(:,:,:),1);
end
% temporal embedding
m=4;
tau=1;
for ph=1:size(population,2)
    if ~isempty(averaged_population{ph})
        xe{ph}=embedding(averaged_population{ph}',m,tau);
        xe{ph}=xe{ph}';
    end
end
X=[];
for ph=1:size(population,2)
    X=[X,xe{ph}];
end
% dimensionality reduction: PCA
[coeff,score,latent] = pca(X');
mappedX=score(:,1:3);
% Plot
f=figure;
n_bins=size(xe{1},2);
fvOn_bin_position = find(-ops.pre:ops.binsize:ops.post==0)-m;
fvOff_bin_position = find(-ops.pre:ops.binsize:ops.post==1)-m;
hold on;
start_bin = 1;
for ii = 1:size(population,2)
    plot3(mappedX(start_bin:start_bin+n_bins-1,1), mappedX(start_bin:start_bin+n_bins-1,2), mappedX(start_bin:start_bin+n_bins-1,3), ...
    'Color', lineProps.col{ii,1}, 'LineWidth', 1.5);
    % Plot fv_on
    % h=plot3(mappedX(start_bin,1), mappedX(start_bin,2),mappedX(start_bin,3),'ko');
    h=plot3(mappedX(start_bin+fvOn_bin_position,1), mappedX(start_bin+fvOn_bin_position,2),mappedX(start_bin+fvOn_bin_position,3),'ko');
    % Plot fv_off
    % h=plot3(mappedX(fvOff_bin_position+start_bin-1,1), mappedX(fvOff_bin_position+start_bin-1,2),mappedX(fvOff_bin_position+start_bin-1,3),'k*');
    h=plot3(mappedX(start_bin+fvOff_bin_position,1), mappedX(start_bin+fvOff_bin_position,2),mappedX(start_bin+fvOff_bin_position,3),'k*');
    start_bin = start_bin+n_bins;
end
grid on;
hold off
xlabel('PC1');
ylabel('PC2');
zlabel('PC3');
set_fonts();
f.Units = 'centimeters';
f.Position = [3 3 6 3];
end