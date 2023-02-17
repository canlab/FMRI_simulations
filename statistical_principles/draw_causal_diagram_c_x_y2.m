rad = 0.1;
eoffset = 0.4;

fillcolor = [.8 .8 .8];

create_figure('causal diagram');
title('Causal model')
axis equal
set(gca, 'XLim', [-0.5 2.5], 'YLim', [-.2-eoffset .2+eoffset])
axis off

h = [];

% Main layer - observed vars
h(1:2) = draw_a_shape([0 0], rad, 'square', 'C', fillcolor);
h(3:4) = draw_a_shape([1 0], rad, 'square', 'X', fillcolor);
h(5:6) = draw_a_shape([2 0], rad, 'square', 'Y', fillcolor);

% noise layer
% draw noise circles
h(7:8) = draw_a_shape([0 eoffset], rad, 'circle', 'Ce', fillcolor);
h(9:10) = draw_a_shape([1 eoffset], rad, 'circle', 'Xe', fillcolor);
h(11:12) = draw_a_shape([2 eoffset], rad, 'circle', 'Ye', fillcolor);

arrow([0 eoffset-rad], [0 0+rad]);
arrow([1 eoffset-rad], [1 0+rad]);
arrow([2 eoffset-rad], [2 0+rad]);

text(0+textoffset, eoffset, 'Ce', 'FontWeight', 'b', 'FontSize', 14);
text(1+textoffset, eoffset, 'Xe', 'FontWeight', 'b', 'FontSize', 14);
text(2+textoffset, eoffset, 'Ye', 'FontWeight', 'b', 'FontSize', 14);

% true signal layer layer
h4 = circle([0 -eoffset], rad, 'fill', fillcolor);
h5 = circle([1 -eoffset], rad, 'fill', fillcolor);
h6 = circle([2 -eoffset], rad, 'fill', fillcolor);

arrow([0 -eoffset+rad], [0 0-rad]);
arrow([1 -eoffset+rad], [1 0-rad]);
arrow([2 -eoffset+rad], [2 0-rad]);

text(0+textoffset, -eoffset, 'Cs', 'FontWeight', 'b', 'FontSize', 14);
text(1+textoffset, -eoffset, 'Xs', 'FontWeight', 'b', 'FontSize', 14);
text(2+textoffset, -eoffset, 'Ys', 'FontWeight', 'b', 'FontSize', 14);

% causal paths
arrow([0+rad -eoffset], [1-rad 0]);  % diff from 1st case
arrow([1+rad -eoffset], [2-rad -eoffset]);

text(0.4, -rad, 'a', 'FontWeight', 'b', 'FontSize', 14); % diff from 1st case
text(1.5, rad-eoffset, 'b', 'FontWeight', 'b', 'FontSize', 14);

disp('Causal model for "effect_sizes_c_causes_x_error_only"')

% ------------------------------------------------------------------------

function [h1 h2] = draw_a_shape(centerposition, rad, shapetype, textlabel, fillcolor)
% [h1 h2] = draw_a_shape(centerposition, shapetype, rad [radius or half-width], textlabel, fillcolor)
% [h1 h2] = draw_a_shape([0 0], 'square', 'C', fillcolor)

textoffset = -0.04;

switch shapetype
    case 'circle'
        h1 = circle([centerposition(1) centerposition(2)], rad, 'fill', fillcolor);

    case 'square'
        h1 = drawbox(centerposition(1)-rad, 2*rad, centerposition(2)-rad, 2*rad, fillcolor);
        
    otherwise error('unknown shape type. enter circle or square.')
end

h2 = text(centerposition(1)+textoffset, centerposition(2), textlabel, 'FontWeight', 'b', 'FontSize', 14);

end


