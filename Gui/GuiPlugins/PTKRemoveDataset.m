classdef PTKRemoveDataset < PTKGuiPlugin
    % PTKClearDiskCache. Gui Plugin for removing a dataset.
    %
    %     You should not use this class within your own code. It is intended to
    %     be used by the gui of the Pulmonary Toolkit.
    %
    %     PTKRemoveDataset is a Gui Plugin for the TD Pulmonary Toolkit. 
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
        ButtonText = 'Delete dataset'
        SelectedText = 'Delete dataset'
        ToolTip = 'Remove this dataset from the Toolkit'
        Category = 'Dataset'
        Visibility = 'Dataset'
        Mode = 'Toolbar'
        Icon = 'bin.png'
        Location = 3

        HidePluginInDisplay = false
        PTKVersion = '1'
        ButtonWidth = 4
        ButtonHeight = 1
    end
    
    methods (Static)
        function RunGuiPlugin(ptk_gui_app)
            % Delete files from the disk cache
            ptk_gui_app.DeleteThisImageInfo;
        end
        
        function enabled = IsEnabled(ptk_gui_app)
            enabled = ptk_gui_app.IsDatasetLoaded;
        end
        
        function is_selected = IsSelected(ptk_gui_app)
            is_selected = false;
        end        
    end
    
end

