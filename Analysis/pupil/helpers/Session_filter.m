%% Fliter out bad sessions
% Exclusion criteria: >10% of the data with likelihood lower than 0.98
% Need to be modified

function Session_filter(Videolist_csv)

for ses = 1:numel(Videolist_csv)
    opts = detectImportOptions(Videolist_csv{ses});
    opts.VariableNamesLine = 3;
    opts.Delimiter = ',';
    opts.RowNamesColumn = 1;
    coords = readtable(Videolist_csv{ses}, opts, 'ReadVariableNames', true);
    
    likelihood_columns = coords{:,[4:3:25]};
    %need to be modified: one of the likelihood column pairs (e.g. north south), the likelihood is lower than 0.98  
    n_LowerThan98 = nnz(likelihood_columns<0.98);
    percent_LowerThan98 = n_LowerThan98/(numel(likelihood_columns));
    
    if percent_LowerThan98 > 0.1
        fprintf('%s is excluded \n', Videolist_csv{ses});
        Videolist_csv(ses) = [];
    end
end
