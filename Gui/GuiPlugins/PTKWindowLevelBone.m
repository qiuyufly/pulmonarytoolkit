classdef PTKWindowLevelBone < PTKGuiPlugin
    % PTKWindowLevelBone. Gui Plugin for using a preset bone window/level
    %
    %     You should not use this class within your own code. It is intended to
    %     be used by the gui of the Pulmonary Toolkit.
    %
    %     PTKWindowLevelBone is a Gui Plugin for the TD Pulmonary Toolkit.
    %     The gui will create a button for the user to run this plugin.
    %     Running this plugin will change the window and level of the viewing 
    %     panel to standard soft tissue values.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %    
    
    properties
        ButtonText = 'Bone preset'
        SelectedText = 'Bone preset'
        ToolTip = 'Changes the window and level settings to standard bone values (Window 2000HU Level 300HU)'
        Category = 'Window/Level Presets'
        Visibility = 'Dataset'
        Mode = 'View'

        HidePluginInDisplay = false
        PTKVersion = '1'
        ButtonWidth = 6
        ButtonHeight = 1
        Icon = 'wl_bone.png'
        Location = 2
    end
    
    methods (Static)
        function RunGuiPlugin(ptk_gui_app)
            ptk_gui_app.ImagePanel.Window = 2000;
            ptk_gui_app.ImagePanel.Level = 300;
        end
        
        function enabled = IsEnabled(ptk_gui_app)
            enabled = ptk_gui_app.IsDatasetLoaded;
        end
        
        function is_selected = IsSelected(ptk_gui_app)
            is_selected = ptk_gui_app.ImagePanel.Window == 2000 && ptk_gui_app.ImagePanel.Level == 300;
        end

    end
end