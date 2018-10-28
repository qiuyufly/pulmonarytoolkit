classdef PTKExportEditedImage < PTKGuiPlugin
    % PTKExportEditedImage. Gui Plugin 
    %
    %     You should not use this class within your own code. It is intended to
    %     be used by the gui of the Pulmonary Toolkit.
    %
    %     PTKExportEditedImage is a Gui Plugin for the TD Pulmonary Toolkit.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %    

    properties
        ButtonText = 'Export Edit'
        SelectedText = 'Export Edit'
        ToolTip = 'Exports the current edit to an external file'
        Category = 'Import / Export'
        Visibility = 'Overlay'
        Mode = 'Edit'

        HidePluginInDisplay = false
        PTKVersion = '1'
        ButtonWidth = 6
        ButtonHeight = 2
    end
    
    methods (Static)
        function RunGuiPlugin(ptk_gui_app)
            ptk_gui_app.GetMode.ExportEdit;
        end
    end
end