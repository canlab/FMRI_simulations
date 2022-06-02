

% 2011 Placebo-predictive maps
[PlaceboPvsC_Antic, names] = load_image_set('PlaceboPvsC_Antic');
[PlaceboPvsC_Pain, names] = load_image_set('PlaceboPvsC_Pain');

%%


create_figure('montage'); axis off; h = montage(PlaceboPvsC_Antic);
h.title_montage(5, 'Placebo-predictive, Anticipation (2011)');

create_figure('montage'); axis off; h = montage(PlaceboPvsC_Pain);
h.title_montage(5, 'Placebo-predictive, During Pain (2011)');

%%

% Cerebellar regions

create_figure('wedge'); h = wedge_plot_by_atlas(PlaceboPvsC_Antic, 'atlases', {'cerebellum'}, 'montage');

