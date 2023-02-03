Introduction to CANlab fMRI design tools

% optimizeGA, onsets2fmridesign, plotDesign, onsets2power, onsets2efficiency, onsets2singletrial
% create_block_design, create_design_single_event, create_random_er_design, create_random_onsets
% calcEfficiency
% tor_make_deconv_mtx3

[X, e, onsets] = create_random_er_design(1, 1.3, 1, [.2 .2], 180, 0);