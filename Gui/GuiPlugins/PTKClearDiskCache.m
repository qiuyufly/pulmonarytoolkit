classdef PTKClearDiskCache < PTKGuiPlugin
    % PTKClearDiskCache. Gui Plugin for deleting all cached results files for the current dataset
    %
    %     You should not use this class within your own code. It is intended to
    %     be used by the gui of the Pulmonary Toolkit.
    %
    %     PTKClearDiskCache is a Gui Plugin for the TD Pulmonary Toolkit. 
    %     The gui will create a button for the user to run this plugin.
    %     Running this plugin will delete all results files from the current 
    %     dataset results cache folder. Certain internal cache files will not be
    %     removed.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %    
    
    properties
        ButtonText = 'Delete Cache'
        SelectedText = 'Delete Cache'
        ToolTip = 'Clear all cached results for this dataset'
        Category = 'Delete cache'
        Visibility = 'Dataset'
        Mode = 'View'

        HidePluginInDisplay = false
        PTKVersion = '1'
        ButtonWidth = 4
        ButtonHeight = 1
        Location = 13
    end
    
    methods (Static)
        function RunGuiPlugin(ptk_gui_app)
            % Delete files from the disk cache and update the plugin previews
            ptk_gui_app.ClearCacheForThisDataset;
        end
        
        function enabled = IsEnabled(ptk_gui_app)
            enabled = ptk_gui_app.DeveloperMode && ptk_gui_app.IsDatasetLoaded;
        end        
    end
    
end

