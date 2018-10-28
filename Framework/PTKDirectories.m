classdef PTKDirectories < PTKBaseClass
    % PTKDirectories. Part of the internal framework of the Pulmonary Toolkit.
    %
    %     You should not use this class within your own code. It is intended to
    %     be used internally within the framework of the Pulmonary Toolkit.
    %
    %     Used to find directories used by the Toolkit.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %


    methods (Static)
        function application_directory = GetApplicationDirectoryAndCreateIfNecessary
            if ~isempty(PTKConfig.CacheFolder)
                home_directory = PTKConfig.CacheFolder;
            else
                home_directory = PTKDiskUtilities.GetUserDirectory;
            end
            application_directory = PTKSoftwareInfo.ApplicationSettingsFolderName;
            application_directory = fullfile(home_directory, application_directory);  
            if ~exist(application_directory, 'dir')
                mkdir(application_directory);
            end
        end

        function cache_directory = GetCacheDirectory
            % Get the parent folder in which dataset cache folders are stored
            
            application_directory = PTKDirectories.GetApplicationDirectoryAndCreateIfNecessary;
            cache_directory = PTKSoftwareInfo.DiskCacheFolderName;
            cache_directory = fullfile(application_directory, cache_directory);
        end

        function settings_file_path = GetSettingsFilePath
            % Returns the full path to the settings file
            
            settings_dir = PTKDirectories.GetApplicationDirectoryAndCreateIfNecessary;
            settings_filename = PTKSoftwareInfo.SettingsFileName;
            settings_file_path = fullfile(settings_dir, settings_filename);
        end
        
        function source_directory = GetSourceDirectory
            % Returns the full path to root of the PTK source code
        
            full_path = mfilename('fullpath');
            [path_root, ~, ~] = fileparts(full_path);
            source_directory = fullfile(path_root, '..');
        end
        
        function source_directory = GetTestSourceDirectory
            % Returns the full path to root of the PTK test source code
        
            full_path = mfilename('fullpath');
            [path_root, ~, ~] = fileparts(full_path);
            source_directory = fullfile(path_root, '..', PTKSoftwareInfo.TestSourceDirectory);
        end
        
        function mex_source_directory = GetMexSourceDirectory
            % Returns the full path to the mex file directory
            
            mex_source_directory = fullfile(PTKDirectories.GetSourceDirectory, PTKSoftwareInfo.MexSourceDirectory);
        end

        function results_directory = GetOutputDirectoryAndCreateIfNecessary
            % Returns the full path to the directory used for storing results
            
            application_directory = PTKDirectories.GetApplicationDirectoryAndCreateIfNecessary;
            results_directory = fullfile(application_directory, PTKSoftwareInfo.OutputDirectoryName);
            PTKDiskUtilities.CreateDirectoryIfNecessary(results_directory);
        end
        
        function edited_results_directory = GetEditedResultsDirectoryAndCreateIfNecessary
            % Returns the full path to the directory used for storing results
            
            application_directory = PTKDirectories.GetApplicationDirectoryAndCreateIfNecessary;
            edited_results_directory = fullfile(application_directory, PTKSoftwareInfo.EditedResultsDirectoryName);
            PTKDiskUtilities.CreateDirectoryIfNecessary(edited_results_directory);
        end

        function framework_file_path = GetFrameworkCacheFilePath
            % Returns the full path to the framework cache file
            
            settings_dir = PTKDirectories.GetApplicationDirectoryAndCreateIfNecessary;
            cache_filename = PTKSoftwareInfo.FrameworkCacheFileName;
            framework_file_path = fullfile(settings_dir, cache_filename);
        end
        
        function linking_file_path = GetLinkingCacheFilePath
            % Returns the full path to the linking cache file
            
            settings_dir = PTKDirectories.GetApplicationDirectoryAndCreateIfNecessary;
            cache_filename = PTKSoftwareInfo.LinkingCacheFileName;
            linking_file_path = fullfile(settings_dir, cache_filename);
        end
        
        function settings_file_path = GetImageDatabaseFilePath
            % Returns the full path to the image database file
            
            settings_dir = PTKDirectories.GetApplicationDirectoryAndCreateIfNecessary;
            cache_filename = PTKSoftwareInfo.ImageDatabaseFileName;
            settings_file_path = fullfile(settings_dir, cache_filename);
        end
        
        function plugin_name_list = GetListOfPlugins
            plugin_name_list = PTKDirectories.GetAllMatlabFilesInFolders(PTKDirectories.GetListOfPluginFolders);
        end
        
        function plugin_folders = GetListOfPluginFolders
            plugin_folders = PTKDiskUtilities.GetRecursiveListOfDirectories(PTKDirectories.GetPluginsPath);
        end
        
        function plugin_name_list = GetListOfUserPlugins
            plugin_name_list = PTKDirectories.GetAllMatlabFilesInFolders(PTKDirectories.GetListOfUserPluginFolders);
        end
        
        function plugin_folders = GetListOfUserPluginFolders
            plugin_folders = PTKDiskUtilities.GetRecursiveListOfDirectories(PTKDirectories.GetUserPluginsPath);
        end
        
        function plugin_name_list = GetListOfGuiPlugins
            plugin_name_list = PTKDirectories.GetAllMatlabFilesInFolders(PTKDirectories.GetListOfGuiPluginFolders);
        end
        
        function plugin_folders = GetListOfGuiPluginFolders
            plugin_folders = PTKDiskUtilities.GetRecursiveListOfDirectories(PTKDirectories.GetGuiPluginsPath);
        end
        
        function plugin_name_list = GetListOfUserGuiPlugins
            plugin_name_list = PTKDirectories.GetAllMatlabFilesInFolders(PTKDirectories.GetListOfUserGuiPluginFolders);
        end
        
        function plugin_folders = GetListOfUserGuiPluginFolders
            plugin_folders = PTKDiskUtilities.GetRecursiveListOfDirectories(PTKDirectories.GetGuiUserPluginsPath);
        end
        
        function matlab_name_list = GetAllMatlabFilesInFolders(folders_to_scan)
            folders_to_scan = PTKStack(folders_to_scan);
            plugins_found = PTKStack;
            while ~folders_to_scan.IsEmpty
                next_folder = folders_to_scan.Pop;
                next_plugin_list = PTKDiskUtilities.GetDirectoryFileList(next_folder.First, '*.m');
                for next_plugin = next_plugin_list
                    plugins_found.Push(PTKPair(PTKTextUtilities.StripFileparts(next_plugin{1}), next_folder.Second));
                end
            end
            matlab_name_list = plugins_found.GetAndClear;
        end
        
        function plugins_path = GetPluginsPath
            full_path = mfilename('fullpath');
            [path_root, ~, ~] = fileparts(full_path);
            plugins_path = fullfile(path_root, '..', PTKSoftwareInfo.PluginDirectoryName);
        end
        
        function plugins_path = GetUserPluginsPath
            full_path = mfilename('fullpath');
            [path_root, ~, ~] = fileparts(full_path);
            plugins_path = fullfile(path_root, '..', PTKSoftwareInfo.UserDirectoryName, PTKSoftwareInfo.PluginDirectoryName);
        end
        
        function plugins_path = GetUserPath
            full_path = mfilename('fullpath');
            [path_root, ~, ~] = fileparts(full_path);
            plugins_path = fullfile(path_root, '..', PTKSoftwareInfo.UserDirectoryName);
        end
        
        function plugins_path = GetGuiPluginsPath
            full_path = mfilename('fullpath');
            [path_root, ~, ~] = fileparts(full_path);
            plugins_path = fullfile(path_root, '..', PTKSoftwareInfo.GuiPluginDirectoryName);
        end
        
        function plugins_path = GetGuiUserPluginsPath
            full_path = mfilename('fullpath');
            [path_root, ~, ~] = fileparts(full_path);
            plugins_path = fullfile(path_root, '..', PTKSoftwareInfo.UserDirectoryName, PTKSoftwareInfo.GuiPluginDirectoryName);
        end
        
        function log_file_path = GetLogFilePath
            settings_folder = PTKDirectories.GetApplicationDirectoryAndCreateIfNecessary;
            log_file_name = PTKSoftwareInfo.LogFileName;
            log_file_path = fullfile(settings_folder, log_file_name);
        end
        
        function is_framework_file = IsFrameworkFile(file_name)
            is_framework_file = strcmp(file_name, [PTKSoftwareInfo.SchemaCacheName '.mat']) || ...
                strcmp(file_name, [PTKSoftwareInfo.ImageInfoCacheName '.mat']) || ...
                strcmp(file_name, [PTKSoftwareInfo.MakerPointsCacheName '.mat']) || ...
                strcmp(file_name, [PTKSoftwareInfo.MakerPointsCacheName '.raw']);
        end
        
        function uids = GetUidsOfAllDatasetsInCache
            cache_directory = PTKDirectories.GetCacheDirectory;
            subdirectories = PTKDiskUtilities.GetListOfDirectories(cache_directory);
            uids = {};
            for subdir = subdirectories
                candidate_uid = subdir{1};
                full_file_name = [cache_directory, filesep, candidate_uid, filesep, PTKSoftwareInfo.ImageInfoCacheName, '.mat'];
                if 2 == exist(full_file_name, 'file')
                    uids{end+1} = candidate_uid;
                end
            end
        end
        
    end
end

