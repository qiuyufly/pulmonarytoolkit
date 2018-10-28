function PTKAddPaths(varargin)
    
    force = nargin > 0 && strcmp(varargin{1}, 'force');
    
    % This version number should be incremented whenever new paths are added to
    % the list
    PTKAddPaths_Version_Number = 1;
    
    persistent PTK_PathsHaveBeenSet
    
    full_path = mfilename('fullpath');
    [path_root, ~, ~] = fileparts(full_path);
    
    if force || (isempty(PTK_PathsHaveBeenSet) || PTK_PathsHaveBeenSet ~= PTKAddPaths_Version_Number)
        
        path_folders = {};
        
        % List of folders to add to the path
        path_folders{end + 1} = '';
        path_folders{end + 1} = 'User';
        path_folders{end + 1} = 'bin';
        path_folders{end + 1} = 'Gui';
        path_folders{end + 1} = fullfile('Gui', 'Tools');
        path_folders{end + 1} = fullfile('Gui', 'Modes');

        path_folders{end + 1} = 'Library';
        path_folders{end + 1} = 'Test';
        path_folders{end + 1} = fullfile('Library', 'Airways');
        path_folders{end + 1} = fullfile('Library', 'mex');
        path_folders{end + 1} = fullfile('Library', 'Analysis');
        path_folders{end + 1} = fullfile('Library', 'Conversion');
        path_folders{end + 1} = fullfile('Library', 'Dicom');
        path_folders{end + 1} = fullfile('Library', 'File');
        path_folders{end + 1} = fullfile('Library', 'GuiComponents');
        path_folders{end + 1} = fullfile('Library', 'Interfaces');
        path_folders{end + 1} = fullfile('Library', 'Lobes');
        path_folders{end + 1} = fullfile('Library', 'Lungs');
        path_folders{end + 1} = fullfile('Library', 'Registration');
        path_folders{end + 1} = fullfile('Library', 'Segmentation');
        path_folders{end + 1} = fullfile('Library', 'Test');
        path_folders{end + 1} = fullfile('Library', 'Types');
        path_folders{end + 1} = fullfile('Library', 'Vessels');
        path_folders{end + 1} = fullfile('Library', 'Utilities');
        path_folders{end + 1} = fullfile('Library', 'Visualisation');
        path_folders{end + 1} = 'Framework';
        
        path_folders{end + 1} = fullfile('External');
        path_folders{end + 1} = fullfile('External', 'gerardus', 'matlab', 'PointsToolbox');
        path_folders{end + 1} = fullfile('External', 'stlwrite');
        path_folders{end + 1} = fullfile('External', 'npReg');
        path_folders{end + 1} = fullfile('External', 'npReg', 'npRegLib');
        path_folders{end + 1} = fullfile('External', 'C_Language');
        
        AddToPath(path_root, path_folders)
        
        
        
        % Now add the plugins (have to do this afterwards, because we rely on
        % library functions, so the library paths have to be set first)
        path_folders = {};
        
        plugin_folders = PTKDiskUtilities.GetRecursiveListOfDirectories(fullfile(path_root, 'Gui', 'GuiPlugins'));
        for folder = plugin_folders
            path_folders{end + 1} = folder{1}.First;
        end
        
        plugin_folders = PTKDiskUtilities.GetRecursiveListOfDirectories(fullfile(path_root, 'Plugins'));
        for folder = plugin_folders
            path_folders{end + 1} = folder{1}.First;
        end
        
        AddToPath('', path_folders);
        
        PTK_PathsHaveBeenSet = PTKAddPaths_Version_Number;
    end
    
    % Add additional user-specific paths specified in the file
    % User/PTKAddUserPaths.m if it exists
    if ~PTKSoftwareInfo.DemoMode
        user_function_name = 'PTKAddUserPaths';
        user_add_paths_function = fullfile(path_root, 'User', [user_function_name '.m']);
        if exist(user_add_paths_function, 'file')
            if force
                feval(user_function_name, 'force');
            else
                feval(user_function_name);
            end
        end
    end
end

function AddToPath(path_root, path_folders)
    full_paths_to_add = {};
    
    % Get the full path for each folder but check it exists before adding to
    % the list of paths to add
    for i = 1 : length(path_folders)
        full_path_name = fullfile(path_root, path_folders{i});
        if exist(full_path_name, 'dir')
            full_paths_to_add{end + 1} = full_path_name;
        end
    end
    
    
    % Add all the paths together (much faster than adding them individually)
    if ~isempty(full_paths_to_add) 
        addpath(full_paths_to_add{:});
    end
    
end