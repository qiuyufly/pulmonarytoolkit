classdef PTKOutputFolder < PTKBaseClass
    % PTKOutputFolder. Part of the internal framework of the Pulmonary Toolkit.
    %
    %     You should not use this class within your own code. It is intended to
    %     be used internally within the framework of the Pulmonary Toolkit.
    %
    %     PTKOutputFolder is used to save and keep track of results and graphs saved
    %     to the output folder.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    properties (Access = private)        
        OutputFolder % Caches the output folder for this dataset        
        OutputRecords % Records of files stored in the Output folder
        
        DatasetDiskCache % Used for persisting the records between sessions
        ImageTemplates
        ImageUid
        
        ChangedFolders % List of output folders which have been modified since last call to OpenChangedFolders
    end
    
    methods
        function obj = PTKOutputFolder(dataset_disk_cache, image_info, image_templates, reporting)
            obj.DatasetDiskCache = dataset_disk_cache;
            obj.ImageTemplates = image_templates;
            obj.ImageUid = image_info.ImageUid;
            
            obj.OutputRecords = PTKOutputInfo.empty;
            
            % Loads cached template data
            obj.Load(reporting);
        end
        
        function SaveTableAsCSV(obj, plugin_name, subfolder_name, file_name, description, table, file_dim, row_dim, col_dim, filters, dataset_stack, reporting)
            date_text = date;
            output_folder = obj.GetOutputPath(dataset_stack, reporting);
            file_path = fullfile(output_folder, subfolder_name);
            ptk_file_name = PTKFilename(file_path, file_name);
            new_record = PTKOutputInfo(plugin_name, description, ptk_file_name, date_text);
            PTKDiskUtilities.CreateDirectoryIfNecessary(file_path);
            PTKSaveTableAsCSV(file_path, file_name, table, file_dim, row_dim, col_dim, filters, reporting);
            obj.AddRecord(new_record, reporting);
            obj.ChangedFolders{end + 1} = file_path;
        end

        function SaveFigure(obj, figure_handle, plugin_name, subfolder_name, file_name, description, dataset_stack, reporting)
            date_text = date;
            output_folder = obj.GetOutputPath(dataset_stack, reporting);
            file_path = fullfile(output_folder, subfolder_name);
            ptk_file_name = PTKFilename(file_path, file_name);
            new_record = PTKOutputInfo(plugin_name, description, ptk_file_name, date_text);
            PTKDiskUtilities.CreateDirectoryIfNecessary(file_path);
            PTKDiskUtilities.SaveFigure(figure_handle, fullfile(file_path, file_name));
            obj.AddRecord(new_record, reporting);
            obj.ChangedFolders{end + 1} = file_path;
        end
        
        function SaveSurfaceMesh(obj, plugin_name, subfolder_name, file_name, description, segmentation, smoothing_size, small_structures, coordinate_system, template_image, dataset_stack, reporting)
            date_text = date;
            output_folder = obj.GetOutputPath(dataset_stack, reporting);
            file_path = fullfile(output_folder, subfolder_name);
            ptk_file_name = PTKFilename(file_path, file_name);
            new_record = PTKOutputInfo(plugin_name, description, ptk_file_name, date_text);
            PTKDiskUtilities.CreateDirectoryIfNecessary(file_path);
            PTKCreateSurfaceMesh(file_path, file_name, segmentation, smoothing_size, small_structures, coordinate_system, template_image, reporting);
            obj.AddRecord(new_record, reporting);
            obj.ChangedFolders{end + 1} = file_path;
        end

        function RecordNewFileAdded(obj, plugin_name, file_path, file_name, description, reporting)
            date_text = date;
            ptk_file_name = PTKFilename(file_path, file_name);
            new_record = PTKOutputInfo(plugin_name, description, ptk_file_name, date_text);
            obj.AddRecord(new_record, reporting);
            obj.ChangedFolders{end + 1} = file_path;
        end

        function OpenChangedFolders(obj, reporting)
            obj.ChangedFolders = unique(obj.ChangedFolders);
            for folder = obj.ChangedFolders'
                reporting.OpenPath(folder{1}, 'New analysis result files have been added to the following output path');
            end
            obj.ChangedFolders = [];
        end
        
        function cache_path = GetOutputPath(obj, dataset_stack, reporting)
            if isempty(obj.OutputFolder)
                obj.CreateNewOutputFolder(dataset_stack, reporting)
            end
            cache_path = obj.OutputFolder;
        end        
    end
    
    
    methods (Access = private)

        function AddRecord(obj, new_record, reporting)
            obj.OutputRecords(end + 1) = new_record;
            obj.Save(reporting);
        end
        
        function Load(obj, reporting)
            % Retrieves previous records from the disk cache
        
            if obj.DatasetDiskCache.Exists(PTKSoftwareInfo.OutputFolderCacheName, [], reporting)
                info = obj.DatasetDiskCache.LoadData(PTKSoftwareInfo.OutputFolderCacheName, reporting);
                obj.OutputRecords = info.OutputRecords;
                if isfield(info, 'OutputFolder')
                    obj.OutputFolder = info.OutputFolder;
                else
                    obj.OutputFolder = [];
                end
            else
                obj.OutputFolder = [];
            end
        end
        
        function Save(obj, reporting)
            % Stores current records in the disk cache
            
            info = [];
            info.OutputRecords = obj.OutputRecords;
            obj.DatasetDiskCache.SaveData(PTKSoftwareInfo.OutputFolderCacheName, info, reporting);
        end
        
        function CreateNewOutputFolder(obj, dataset_stack, reporting)
            root_output_path = PTKDirectories.GetOutputDirectoryAndCreateIfNecessary;
            
            template = obj.ImageTemplates.GetTemplateImage(PTKContext.LungROI, dataset_stack, reporting);
            metadata = template.MetaHeader;
            
            if isfield(metadata, 'PatientName')
                [~, subfolder] = PTKDicomUtilities.PatientNameToString(metadata.PatientName);
            elseif isfield(metadata, 'PatientId')
                subfolder = metadata.PatientId;
            else
                subfolder = '';
            end
            
            if isempty(subfolder)
                subfolder = obj.ImageUid;
                subsubfolder = '';
            else
                subsubfolder = '';                
                if isfield(metadata, 'StudyDescription')
                    study_description = metadata.StudyDescription;
                else
                    study_description = '';
                end
                if isfield(metadata, 'SeriesDescription')
                    series_description = metadata.SeriesDescription;
                else
                    series_description = '';
                end
                if ~isempty(study_description) && ~isempty(series_description)
                    subsubfolder = [study_description '_' series_description];
                elseif ~isempty(study_description)
                    subsubfolder = study_description;
                elseif ~isempty(series_description)
                    subsubfolder = series_description;
                end
            end

            subfolder = PTKTextUtilities.MakeFilenameValid(subfolder);
            if isempty(subsubfolder)
                obj.OutputFolder = fullfile(root_output_path, subfolder);
            else
                subsubfolder = PTKTextUtilities.MakeFilenameValid(subsubfolder);
                obj.OutputFolder = fullfile(root_output_path, subfolder, subsubfolder);
            end
            
        end
    end
end