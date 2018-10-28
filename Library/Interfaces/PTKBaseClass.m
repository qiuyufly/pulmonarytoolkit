classdef PTKBaseClass < handle
    % PTKBaseClass. Class with event listeners which are auto-deleted
    %
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    properties (Access = protected)
        EventListeners
    end
    
    methods
        function obj = PTKBaseClass
            if PTKSoftwareInfo.MonitorClassInstances
                PTKClassMonitor.GetClassMonitor.ObjectCreated(class(obj));
            end
        end
        
        function delete(obj)
            for listener = obj.EventListeners
                delete(listener{1});
            end
            obj.EventListeners = [];
            
            if PTKSoftwareInfo.MonitorClassInstances
                PTKClassMonitor.GetClassMonitor.ObjectDeleted(class(obj));
            end
        end
    end
    
    methods (Access = protected)
        
        function AddEventListener(obj, control, event_name, function_handle)
            % Adds a new event listener tied to the lifetime of this object
            
            new_listener = addlistener(control, event_name, function_handle);
            obj.EventListeners{end + 1} = new_listener;
        end
        
        function AddPostSetListener(obj, control, event_name, function_handle)
            % Adds a new event listener tied to the lifetime of this object, for the PostSet
            % operation
            
            new_listener = addlistener(control, event_name, 'PostSet', function_handle);
            obj.EventListeners{end + 1} = new_listener;
        end
        
    end
end