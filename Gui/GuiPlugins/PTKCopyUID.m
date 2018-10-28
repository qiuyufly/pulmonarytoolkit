classdef PTKCopyUID < PTKGuiPlugin
    % PTKCopyUID. Copy the UID of the current dataset to the clipboard
    %
    %     You should not use this class within your own code. It is intended to
    %     be used by the gui of the Pulmonary Toolkit.
    %
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %    

    properties
        ButtonText = 'Copy UID'
        SelectedText = 'Copy UID'
        ToolTip = 'Copy the UID of the current dataset to the clipboard'
        Category = 'File'
        Visibility = 'Dataset'
        Mode = 'View'

        HidePluginInDisplay = false
        PTKVersion = '1'
        ButtonWidth = 4
        ButtonHeight = 1
        
        Location = 14        
    end
    
    methods (Static)
        function RunGuiPlugin(ptk_gui_app)
            image_info = ptk_gui_app.GetImageInfo;
            uid = image_info.ImageUid;
            disp(['Current dataset UID is: ' uid]);
            clipboard('copy', uid);
        end
        
        function enabled = IsEnabled(ptk_gui_app)
            enabled = ptk_gui_app.DeveloperMode && ptk_gui_app.IsDatasetLoaded;
        end        
    end
end