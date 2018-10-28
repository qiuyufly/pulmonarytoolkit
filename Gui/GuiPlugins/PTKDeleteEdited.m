classdef PTKDeleteEdited < PTKGuiPlugin
    % PTKDeleteEdited.
    %
    %     You should not use this class within your own code. It is intended to
    %     be used by the gui of the Pulmonary Toolkit.
    %
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %    

    properties
        ButtonText = 'Delete all editing'
        SelectedText = 'Delete all editing'
        ToolTip = ''
        Category = 'Edit'
        Visibility = 'Overlay'
        Mode = 'Edit'

        HidePluginInDisplay = false
        PTKVersion = '1'
        ButtonWidth = 6
        ButtonHeight = 2
    end
    
    methods (Static)
        function RunGuiPlugin(ptk_gui_app)
            
            % ToDo
            ptk_gui_app.GetMode.DeleteAllEditsWithPrompt;
            ptk_gui_app.ImagePanel.DeleteEditLobe;
        end
    end
end