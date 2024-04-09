%% Check which animal and tetrode the VP units come from

VP_units = [17026,17052,29248,29267,33000,33883,35103,40313,40317,47451,47461,47464,43166,16164,16775,29396,33169,33181,33184,33676,33681,34175,39582,39583,39589,39591,40111,40133,40135,43250,43264,16298,17114,29048,29057,33369,34437,34720,34722,38993,39487,39491,40003,40004,43330,43334,43998,44202,44207,40437,40687,18213,41527,41901,45949,18425,41173,41769,41794,45432]; 
load ('/zi-flstorage/data/Angela/DATA/TD23/D-struct/KS3/d_09-Apr-2024.mat')

for vp = 1:numel(VP_units)
    animal{vp} = d.clust_params(VP_units(vp)).animal;
    tetrode{vp} = d.clust_params(VP_units(vp)).tetrode;
end

x04 = numel(find(contains(animal, {'x04'})));
x07 = numel(find(contains(animal, {'x07'})));
x08 = numel(find(contains(animal, {'x08'})));
x09 = numel(find(contains(animal, {'x09'})));
x10 = numel(find(contains(animal, {'x10'})));

x04_tet = tetrode(contains(animal, {'x04'}));
x07_tet = tetrode(contains(animal, {'x07'}));
x08_tet = tetrode(contains(animal, {'x08'}));
x09_tet = tetrode(contains(animal, {'x09'}));
x10_tet = tetrode(contains(animal, {'x10'}));



