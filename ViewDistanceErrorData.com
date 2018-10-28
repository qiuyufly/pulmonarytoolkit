gfx r data LOblique_DistanceDifference
gfx r data RHorizontal_DistanceDifference
gfx r data ROblique_DistanceDifference

gfx modify g_element LOblique_fissure general clear circle_discretization 6 default_coordinate coordinates element_discretization "4*4*4" native_discretization none;
gfx modify g_element LOblique_fissure lines select_on material default selected_material default_selected;
gfx modify g_element LOblique_fissure data_points glyph sphere general size "2*2*2" centre 0,0,0 font default select_on material default data density spectrum default selected_material default_selected;

gfx modify g_element RHorizontal_fissure general clear circle_discretization 6 default_coordinate coordinates element_discretization "4*4*4" native_discretization none;
gfx modify g_element RHorizontal_fissure lines select_on material default selected_material default_selected;
gfx modify g_element RHorizontal_fissure data_points glyph sphere general size "2*2*2" centre 0,0,0 font default select_on material default data density spectrum default selected_material default_selected;

gfx modify g_element ROblique_fissure general clear circle_discretization 6 default_coordinate coordinates element_discretization "4*4*4" native_discretization none;
gfx modify g_element ROblique_fissure lines select_on material default selected_material default_selected;
gfx modify g_element ROblique_fissure data_points glyph sphere general size "2*2*2" centre 0,0,0 font default select_on material default data density spectrum default selected_material default_selected;

gfx modify spectrum default clear overwrite_colour;
gfx modify spectrum default linear reverse range 0 35 extend_above extend_below rainbow colour_range 0 1 component 1;

gfx edit spectrum
gfx cre win
gfx ed sc
