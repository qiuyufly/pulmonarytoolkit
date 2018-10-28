classdef PTKPluginLabelSlider < PTKLabelSlider
    % PTKPluginLabelSlider. Part of the gui for the Pulmonary Toolkit.
    %
    %     This class is used internally within the Pulmonary Toolkit to help
    %     build the user interface.
    %
    %     PTKPluginLabelSlider is used to build a slider control which interacts
    %     with the PTK GUI
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    properties (Access = private)
        GuiApp
        Tool
        FixToInteger = true
    end
    
    methods
        function obj = PTKPluginLabelSlider(parent, tool, icon, gui_app, reporting)
            obj = obj@PTKLabelSlider(parent, tool.ButtonText, tool.ToolTip, class(tool), icon, reporting);
            obj.GuiApp = gui_app;
            obj.Tool = tool;
            
            [instance_handle, value_property_name, limits_property_name] = tool.GetHandleAndProperty(gui_app);
            value = instance_handle.(value_property_name);
            
            if ~isempty(limits_property_name)
                limits = instance_handle.(limits_property_name);
                if ~isempty(limits)
                    min_slider = limits(1);
                    max_slider = limits(2);
                else
                    min_slider = tool.MinValue;
                    max_slider = tool.MaxValue;
                end
            else
                min_slider = tool.MinValue;
                max_slider = tool.MaxValue;
            end
            
            obj.Slider.SetSliderLimits(min_slider, max_slider);
            obj.Slider.SetSliderSteps([tool.SmallStep, tool.LargeStep]);
            obj.Slider.SetSliderValue(value);
            
            obj.EditBoxPosition = tool.EditBoxPosition;
            obj.EditBoxWidth = tool.EditBoxWidth;
            
            if ~isempty(obj.EditBox)
                obj.EditBox.SetText(num2str(value, '%.6g'));
            end
            
            obj.AddPostSetListener(instance_handle, value_property_name, @obj.PropertyChangedCallback);
            
            if ~isempty(limits_property_name)
                obj.AddPostSetListener(instance_handle, limits_property_name, @obj.PropertyLimitsChangedCallback);
            end
        end
        
        function enabled = UpdateToolEnabled(obj, gui_app)
            enabled = obj.Tool.IsEnabled(gui_app);
        end
    end
    
    methods (Access = protected)
        function SliderCallback(obj, hObject, arg2)
            SliderCallback@PTKLabelSlider(obj, hObject, arg2);
            
            [instance_handle, value_property_name, ~] = obj.Tool.GetHandleAndProperty(obj.GuiApp);
            
            value = obj.Slider.SliderValue;
            if obj.FixToInteger
                value = round(value);
            end
            instance_handle.(value_property_name) = value;
            obj.EditBox.SetText(num2str(value, '%.6g'));
        end
        
        function EditBoxCallback(obj, hObject, arg2)
            EditBoxCallback@PTKLabelSlider(obj, hObject, arg2);
            
            [instance_handle, value_property_name, ~] = obj.Tool.GetHandleAndProperty(obj.GuiApp);
            
            value = round(str2double(obj.EditBox.Text));
            instance_handle.(value_property_name) = value;
            obj.Slider.SetSliderValue(value);
        end
        
        function PropertyChangedCallback(obj, ~, ~, ~)
            [instance_handle, value_property_name, ~] = obj.Tool.GetHandleAndProperty(obj.GuiApp);
            value = instance_handle.(value_property_name);
            % Output the changed lobe segmentation parameter
            current_tool=obj.Tool;
            current_path = mfilename('fullpath');
            [path_root, ~, ~] = fileparts(current_path);
            full_filename = fullfile(path_root,'..','User', 'Library', 'PTKSearchingRegionThreshold.txt');
            FidOpen = fopen(full_filename,'r');
            tline1 = fgetl(FidOpen);
            tline2 = fgetl(FidOpen);
            tline3 = fgetl(FidOpen);
            tline4 = fgetl(FidOpen);
            fclose(FidOpen);
            if isa(current_tool, 'PTKLeftObliqueSearchingRegionSlider')
                FidOut = fopen(full_filename,'wt');
                fprintf(FidOut,[tline1(1:26) ' ' num2str(value) '\n']);
                fprintf(FidOut,[tline2 '\n']);
                fprintf(FidOut,[tline3 '\n']);
                fprintf(FidOut,tline4);
                fclose(FidOut);
                obj.GuiApp.ClearLobeSegmentationCacheForThisDataset; % Delete the cache files of lobe segmentation result
            elseif isa(current_tool, 'PTKRightObliqueSearchingRegionSlider')
                FidOut = fopen(full_filename,'wt');
                fprintf(FidOut,[tline1 '\n']);
                fprintf(FidOut,[tline2(1:27) ' ' num2str(value) '\n']);
                fprintf(FidOut,[tline3 '\n']);
                fprintf(FidOut,tline4);
                fclose(FidOut);
                obj.GuiApp.ClearLobeSegmentationCacheForThisDataset; % Delete the cache files of lobe segmentation result
            elseif isa(current_tool, 'PTKRightHorizontalSearchingRegionSlider')
                FidOut = fopen(full_filename,'wt');
                fprintf(FidOut,[tline1 '\n']);
                fprintf(FidOut,[tline2 '\n']);
                fprintf(FidOut,[tline3(1:30) ' ' num2str(value) '\n']);
                fprintf(FidOut,tline4);
                fclose(FidOut); 
                obj.GuiApp.ClearLobeSegmentationCacheForThisDataset; % Delete the cache files of lobe segmentation result
            elseif isa(current_tool, 'PTKConnectedComponentNumber')
                FidOut = fopen(full_filename,'wt');
                fprintf(FidOut,[tline1 '\n']);
                fprintf(FidOut,[tline2 '\n']);
                fprintf(FidOut,[tline3 '\n']);
                fprintf(FidOut,[tline4(1:24) ' ' num2str(value)]);
                fclose(FidOut); 
                obj.GuiApp.ClearPartLobeSegmentationCacheForThisDataset; % Delete the cache files of lobe segmentation result
            end
            
            % Output the changed eigenvector based connected analysis parameter
            current_tool=obj.Tool;
            current_path = mfilename('fullpath');
            [path_root, ~, ~] = fileparts(current_path);
            full_filename = fullfile(path_root,'..','User', 'Library', 'MYEigenvectorConnectedSize.txt');
            FidOpen = fopen(full_filename,'r');
            tline1 = fgetl(FidOpen);
            tline2 = fgetl(FidOpen);
            tline3 = fgetl(FidOpen);
            fclose(FidOpen);
            if isa(current_tool, 'MYLOEigenvectorBasedConnectedNumber')
                FidOut = fopen(full_filename,'wt');
                fprintf(FidOut,[tline1(1:43) ' ' num2str(value) '\n']);
                fprintf(FidOut,[tline2 '\n']);
                fprintf(FidOut,[tline3 '\n']);
                fclose(FidOut);
                obj.GuiApp.ClearPartLobeSegmentationCacheForThisDataset; % Delete the cache files of lobe segmentation result
            elseif isa(current_tool, 'MYROEigenvectorBasedConnectedNumber')
                FidOut = fopen(full_filename,'wt');
                fprintf(FidOut,[tline1 '\n']);
                fprintf(FidOut,[tline2(1:43) ' ' num2str(value) '\n']);
                fprintf(FidOut,[tline3 '\n']);
                fclose(FidOut);
                obj.GuiApp.ClearPartLobeSegmentationCacheForThisDataset; % Delete the cache files of lobe segmentation result
            elseif isa(current_tool, 'MYRHEigenvectorBasedConnectedNumber')
                FidOut = fopen(full_filename,'wt');
                fprintf(FidOut,[tline1 '\n']);
                fprintf(FidOut,[tline2 '\n']);
                fprintf(FidOut,[tline3(1:43) ' ' num2str(value) '\n']);
                fclose(FidOut); 
                obj.GuiApp.ClearPartLobeSegmentationCacheForThisDataset; % Delete the cache files of lobe segmentation result
            end
            obj.Slider.SetSliderValue(value);
            obj.EditBox.SetText(num2str(value, '%.6g'));
        end
        
        function PropertyLimitsChangedCallback(obj, ~, ~, ~)
            [instance_handle, ~, limits_property_name] = obj.Tool.GetHandleAndProperty(obj.GuiApp);
            limits = instance_handle.(limits_property_name);
            obj.Slider.SetSliderLimits(limits(1), limits(2));
            range = limits(2) - limits(1);
            if abs(range) >= 100
                obj.FixToInteger = true;
            else
                obj.FixToInteger = false;
            end
        end
        
    end
end
