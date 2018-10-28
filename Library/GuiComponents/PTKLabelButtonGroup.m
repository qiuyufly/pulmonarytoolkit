classdef PTKLabelButtonGroup < PTKVirtualPanel
    % PTKLabelButtonGroup. Part of the gui for the Pulmonary Toolkit.
    %
    %     PTKLabelButtonGroup is used to display a group of label buttons
    %
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    properties (Access = private)
        Controls
        Title
        BorderAxes
        BackgroundColour
        CachedPanelWidth
        CachedPanelHeight
        CurrentCategoryMap
        ModeName
    end

    properties
        ButtonHorizontalSpacing = 0
        LeftMargin = 0
        RightMargin = 0
        LabelFontSize = 12
    end
    
    methods
        function obj = PTKLabelButtonGroup(parent, title, tooltip, tag, current_category_map, mode, reporting)
            obj = obj@PTKVirtualPanel(parent, reporting);
            obj.Title = title;
            obj.BackgroundColour = PTKSoftwareInfo.BackgroundColour;
            obj.CurrentCategoryMap = current_category_map;
            obj.ModeName = mode;
        end
        
        function CreateGuiComponent(obj, position, reporting)
            if strcmp(obj.Title, 'Eigenvalue based connected component filter tools')
                if ~isempty(obj.BorderAxes)
                    obj.BorderAxes.TopLine = obj.TopBorder;
                    obj.BorderAxes.BottomLine = obj.BottomBorder;
                    obj.BorderAxes.LeftLine = obj.LeftBorder;
                    obj.BorderAxes.RightLine = obj.RightBorder;
                    if ~isempty(obj.BorderColour)
                        obj.BorderAxes.Colour = obj.BorderColour;
                    end
                end
                
                obj.GraphicalComponentHandle = uipanel('Parent', obj.Parent.GetContainerHandle(reporting), 'BorderType', 'none', 'Units', 'pixels', ...
                    'BackgroundColor', obj.BackgroundColour, 'ForegroundColor', 'white', 'ResizeFcn', '', 'Position', position);
                set(obj.GraphicalComponentHandle, 'Title', obj.Title, 'BorderType', 'etchedin');
            end
        end
        
        function new_control = AddControl(obj, new_control, reporting)
            
            obj.Controls{end + 1} = new_control;
            obj.AddChild(new_control, reporting);
            
            obj.CachedPanelHeight = [];
            obj.CachedPanelWidth = [];
            
            if isa(new_control, 'PTKButton')
                obj.AddEventListener(new_control, 'ButtonClicked', @obj.ButtonClickedCallback);
            elseif isa(new_control, 'PTKSlider')
                obj.AddEventListener(new_control, 'SliderValueChanged', @obj.SliderCallback);
            end
        end
        
        function width = GetWidth(obj)
            width = obj.LeftMargin + obj.RightMargin;
            number_of_enabled_buttons = 0;
            for button = obj.Controls
                if button{1}.Enabled
                    width = width + button{1}.GetWidth;
                    number_of_enabled_buttons = number_of_enabled_buttons + 1;
                end
            end
            width = width + max(0, number_of_enabled_buttons-1)*obj.ButtonHorizontalSpacing;
        end
            
        function Resize(obj, new_position)
            if strcmp(obj.Title, 'Eigenvalue based connected component filter tools')
                new_position(4) = new_position(4) + 30;
            end
            Resize@PTKVirtualPanel(obj, new_position);
            
%             if strcmp(obj.Title, 'Fissure Developer tools')
%                 width = new_position(3);
%                 if isempty(obj.CachedPanelHeight) || (width ~= obj.CachedPanelWidth)
%                     obj.ResizePanel(width);
%                 end
%             end
            control_x = new_position(1) + obj.LeftMargin;
            
            control_height = 0;
            
            for control = obj.Controls
                if control{1}.Enabled
                    y_start = new_position(2) + max(0, round((new_position(4) - control{1}.GetRequestedHeight)/2));
                    button_width = control{1}.GetWidth;
                    control{1}.Resize([control_x, y_start, button_width, control{1}.GetRequestedHeight]);
                    control_x = control_x + button_width + obj.ButtonHorizontalSpacing;
                    control_height = max(control_height, control{1}.GetRequestedHeight);
                end
            end
        end
        
        function Update(obj, gui_app)
            % Calls each label button and updates its status.
            
            for control = obj.Controls
                enabled = control{1}.UpdateToolEnabled(gui_app);
                if enabled ~= control{1}.Enabled
                    if enabled
                        if isempty(control{1}.Position)
                            control{1}.Resize([0 0 1 1]);
                        end
                        control{1}.Enable(obj.Reporting);
                    else
                        control{1}.Disable;
                    end
                end
            end
        end
        
        
        function height = GetRequestedHeight(obj, width)
            height = 0;
            for control = obj.Controls
                if control{1}.Enabled
                    height = max(height, control{1}.GetRequestedHeight);
                end
            end
        end
    end
    
    methods (Access = private)
        function ButtonClickedCallback(obj, src, event)
            for control = obj.Controls
                if src ~= control{1}
                    control{1}.Select(false);
                end
            end
        end
        
        function SliderCallback(obj, hObject, ~)
        end 
        
        function ResizePanel(obj, panel_width)
            
            category_map = obj.CurrentCategoryMap;
            button_spacing_w = 10;
            button_spacing_h = 5;
            header_height = 20;
            footer_height = 10;
            left_right_margins = 10;
            
            max_x = panel_width;
            position_x = left_right_margins;
            position_y = 0;
            
            last_y_coordinate = 0;
            row_height = 0;
            
            % Determine coordinates of buttons and the required panel size
            for current_plugin_key = category_map.keys
                current_plugin = category_map(char(current_plugin_key));
                
%                 button_handle = obj.PluginButtonHandlesMap(char(current_plugin_key));
                button_handle = current_plugin.PluginObject;
                button_width = button_handle.ButtonWidth;
                button_height = button_handle.ButtonHeight;
                                
                current_plugin.ParsedPluginInfo.X = position_x;
                current_plugin.ParsedPluginInfo.Y = position_y;
                current_plugin.ParsedPluginInfo.W = button_width;
                current_plugin.ParsedPluginInfo.H = button_height;
                
                last_y_coordinate = position_y;
                row_height = max(row_height, button_height);
                last_row_height = row_height;
                
                category_map(char(current_plugin_key)) = current_plugin;
                
                position_x = position_x + button_spacing_w + button_width;
                if (position_x + button_width) > (max_x - button_spacing_w)
                    position_y = position_y + button_spacing_h + row_height;
                    position_x = left_right_margins;
                    row_height = 0;
                end
                
            end
            
            obj.CachedPanelHeight = last_y_coordinate + last_row_height + header_height + footer_height;
            obj.CachedPanelWidth = panel_width;
            
            % Resize the buttons
            i = 1;
            for current_plugin_key = category_map.keys
                current_plugin = category_map(char(current_plugin_key));
                
                position_x = current_plugin.ParsedPluginInfo.X;
                button_width = current_plugin.ParsedPluginInfo.W;
                button_height = current_plugin.ParsedPluginInfo.H;
                position_y = obj.CachedPanelHeight - button_height - header_height - current_plugin.ParsedPluginInfo.Y;
                
                new_position = [position_x, position_y, button_width, button_height];
                
%                 button_handle = obj.PluginButtonHandlesMap(char(current_plugin_key));
%                 button_handle = current_plugin.PluginObject;
                children_plugin_label_button = obj.Children{i};
                children_plugin_label_button.Children{1}.Resize(new_position);
                children_plugin_label_button.Children{2}.Resize(new_position);
                i = i+1;
%                 button_handle.Resize(new_position);
            end
        end
    end
end
