classdef PTKFilename
    % PTKFilename. A structure for holding a file name
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2013.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %        
    
    properties
        Path
        Name
    end
    
    methods
        function obj = PTKFilename(file_path, file_name)
            if nargin > 0
                obj.Path = file_path;
                obj.Name = file_name;
            end
        end
        
        function file_name = FullFile(obj)
            if isempty(obj.Path)
                file_name = obj.Name;
            elseif isempty(obj.Name)
                file_name = obj.Path;
            else
                file_name = fullfile(obj.Path, obj.Name);
            end
        end
    end
end

