atl = load_atlas('canlab2018_2mm');
atl = select_atlas_subset(atl, {'_OP'});
orthviews(atl);
create_figure('surf'); p = surface_cutaway('ycut_mm', -10);
surface(atl, 'surface_handles', p);
