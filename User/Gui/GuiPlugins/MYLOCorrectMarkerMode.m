classdef MYLOCorrectMarkerMode < PTKGuiPlugin
    % PTKEnterMarkerMode. Gui Plugin for using a preset bone window/level
    %
    %     You should not use this class within your own code. It is intended to
    %     be used by the gui of the Pulmonary Toolkit.
    %
    %     PTKEnterMarkerMode is a Gui Plugin for entering or leaving marker mode.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %    
    
    properties
        ButtonText = 'Select LO Correct Point'
        SelectedText = 'Hide Markers'
        ToolTip = 'Show the landmark points for left oblique fissure correction'
        Category = 'Correct'
        Visibility = 'Dataset'
        Mode = 'Edit'

        HidePluginInDisplay = false
        PTKVersion = '2'
        ButtonWidth = 6
        ButtonHeight = 2
%         Location = 23
%         Icon = 'markers.png'
    end
    
    methods (Static)
        function RunGuiPlugin(ptk_gui_app)
            if ptk_gui_app.ImagePanel.IsInMarkerMode
                ptk_gui_app.ImagePanel.SetControl('W/L');
            else
                ptk_gui_app.ImagePanel.SetControl('MYLOMark');
            end
            
        end

        function enabled = IsEnabled(ptk_gui_app)
            enabled = ptk_gui_app.IsDatasetLoaded;
        end
        
        function is_selected = IsSelected(ptk_gui_app)
            is_selected = ptk_gui_app.ImagePanel.IsInMarkerMode;
        end
    end
end
