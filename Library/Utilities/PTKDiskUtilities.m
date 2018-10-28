classdef PTKDiskUtilities
    % PTKDiskUtilities. Disk-related utility functions.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %    
    
    methods (Static)
        
        function exists = FileExists(path_name, filename)
            % Determine if the file exists
            exists = 2 == exist(fullfile(path_name, filename), 'file');
        end
        
        function exists = DirectoryExists(path_name)
            % Determine if the directory exists
            exists = 7 == exist(path_name, 'dir');
        end
        
        function RecycleFile(path_name, filename, reporting)
            
            if PTKDiskUtilities.FileExists(path_name, filename)
                
                % Switch on recycle bin before deleting
                state = recycle;
                recycle('on');
                
                full_filename = fullfile(path_name, filename);
                delete(full_filename);
                
                % Restore previous recycle bin state
                recycle(state);
            end
            
        end
        
        function BackupFile(path_name, filename, reporting)
            if PTKDiskUtilities.FileExists(path_name, filename)
                new_filename = [filename '_Backup'];
                backup_number = 0;
                while PTKDiskUtilities.FileExists(path_name, new_filename)
                    backup_number = backup_number + 1;
                    new_filename = [filename '_Backup' int2str(backup_number)];                    
                end
                PTKDiskUtilities.RenameFile(path_name, filename, new_filename);                
            end
        end
        
        function renamed = RenameFile(path_name, old_filename, new_filename, reporting)
            if PTKDiskUtilities.FileExists(path_name, old_filename)
                source = fullfile(path_name, old_filename);
                dest = fullfile(path_name, new_filename);
                movefile(source, dest);
                renamed = true;
            else
                renamed = false;
            end
        end
        
        function home_directory = GetUserDirectory
            % Returns a path to the user's home folder
            if (ispc)
                home_directory = getenv('USERPROFILE');
            else
                home_directory = getenv('HOME');
            end
%             home_directory = PTKSoftwareInfo.CacheFolderPath;
        end
        
        function [absolute_file_path, filename] = GetFullFileParts(path_or_filename)
            if exist(path_or_filename, 'dir')
                relative_pathname = path_or_filename;
                filename = '';
            else
                [relative_pathname, name, ext] = fileparts(path_or_filename);
                filename = [name ext];
            end
            current_path = pwd;
            cd(relative_pathname);
            absolute_file_path = pwd;
            cd(current_path)
        end
        
        function file_list = GetDirectoryFileList(path, filename)
            % Returns a list of files in the specified directory
            files = dir(fullfile(path, filename));
            number_files = length(files);
            file_list = {};
            for i = 1 : number_files
                filename = files(i).name;
                isdir = files(i).isdir;
                if (filename(1) ~= '.' && ~isdir)
                    file_list{end + 1} = filename; %#ok<AGROW>
                end
            end
        end
        
        function dir_list = GetListOfDirectories(path)
            % Returns a list of subdirectories in the specified directory
            files = dir(fullfile(path, '*'));
            number_files = length(files);
            dir_list = {};
            for i = 1 : number_files
                filename = files(i).name;
                isdir = files(i).isdir;
                if (filename(1) ~= '.' && isdir)
                    dir_list{end + 1} = filename; %#ok<AGROW>
                end
            end
        end
        
        function dir_list = GetRecursiveListOfDirectories(root_path)
            % Returns a list of all subdirectories in the specified directory, its
            % subdictories and so on
            % The list is returned as an array of PTKPairs. In each PTKPair, the
            % First property is the directory path (relative to the root_path
            % specified in the input parameter), and the Second property is the
            % just the name of the deepest subdirectory
            
            dirs_to_do = PTKStack(PTKPair(root_path, ''));
            dirs_found = PTKStack;
            while ~dirs_to_do.IsEmpty
                next_dir = dirs_to_do.Pop;
                dirs_found.Push(next_dir);
                this_dir_list = PTKDiskUtilities.GetListOfDirectories(next_dir.First);
                for index = 1 : numel(this_dir_list)
                    this_dir_list{index} = PTKPair(fullfile(next_dir.First, this_dir_list{index}), this_dir_list{index});
                end
                dirs_to_do.Push(this_dir_list);
            end
            dir_list = dirs_found.GetAndClear;
        end
        
        function OpenDirectoryWindow(directory_path)
            % Opens an explorer/finder window at the specified path
           if ispc
               
               if ~exist(directory_path, 'dir')
                   error('Directory not found');
               end
               
               dos(['explorer.exe "' directory_path '"']);
           
           elseif ismac
               unix(['Open "' directory_path '"']);
           else
               warning('PTKDiskUtilities:NotImplementedForUnix', 'Not implemented for unix');
           end
        end
        
        function [path, filenames, filter_index] = ChooseFiles(text_to_display, path, allow_multiple_files, file_spec)
            % Displays a dialog for selecting files
            
            if isempty(path)
                path = PTKDiskUtilities.GetUserDirectory;
            end
            
            if (allow_multiple_files)
                ms = 'on';
            else
                ms = 'off';
            end
            
            input_path = path;
            if (input_path(end) ~= filesep)
                input_path = [path filesep];
            end
            
            [filenames, path, filter_index] = uigetfile(file_spec, text_to_display, input_path, 'MultiSelect', ms);
            if (length(filenames) == 1) && (filenames == 0)
                path = [];
                filenames = [];
                filter_index = [];
            end
            if (~iscell(filenames))
                filenames = {filenames};
            end
        end
        
        function folder_path = ChooseDirectory(text_to_display, folder_path)
            % Displays a dialog for selecting a folder
            
            if isempty(folder_path)
                folder_path = PTKDiskUtilities.GetUserDirectory;
            end
            
            input_path = folder_path;
            if (input_path(end) ~= filesep)
                input_path = [folder_path filesep];
            end
            
            folder_path = uigetdir(input_path, text_to_display);
            
            if folder_path == 0
                folder_path = [];
            end
        end
        
        function [filename, path_name, save_type] = SaveImageDialogBox(path_name)
            % Dialog for exporting a 2D image
            filespec = {...
                '*.tif', 'TIF (*.tif)';
                '*.jpg', 'JPG (*.jpg)';
                };
            
            if isempty(path_name) || ~ischar(path_name) || exist(path_name, 'dir') ~= 7
                path_name = '';
            end
            
            [filename, path_name, filter_index] = uiputfile(filespec, 'Save image as', fullfile(path_name, ''));
            switch filter_index
                case 1
                    save_type = 'tif';
                case 2
                    save_type = 'jpg';
                otherwise
                    save_type = [];
            end
            
        end

        function dicom_filenames = RemoveNonDicomFiles(image_path, filenames)
            dicom_filenames = [];
            for index = 1 : length(filenames)
                if (PTKDicomUtilities.IsDicom(image_path, filenames{index}))
                    dicom_filenames{end + 1} = filenames{index};
                end
            end
        end
        
        function image_info = GetListOfDicomFiles(image_path)
            filenames = PTKTextUtilities.SortFilenames(PTKDiskUtilities.GetDirectoryFileList(image_path, '*'));
            filenames = PTKDiskUtilities.RemoveNonDicomFiles(image_path, filenames);
            image_type = PTKImageFileFormat.Dicom;            
            image_info = PTKImageInfo(image_path, filenames, image_type, [], [], []);
        end

        function CreateDirectoryIfNecessary(dir_name)
            if ~(exist(dir_name, 'dir') == 7)
                mkdir(dir_name);
            end
        end
        
        function [is_meta_header, raw_filename] = IsFileMetaHeader(header_filename, reporting)
            meta_header = PTKDiskUtilities.ReadMetaHeader(header_filename, reporting);
            if (~isempty(meta_header)) && isfield(meta_header, 'ElementDataFile')
                is_meta_header = true;
                raw_filename = meta_header.ElementDataFile;
            else
                is_meta_header = false;
                raw_filename = [];
            end
        end
        
        function meta_header = ReadMetaHeader(header_filename, reporting)
            file_id = fopen(header_filename);
            if (file_id <= 0)
                reporting.Error('PTKDiskUtilities:OpenFileFailed', ['Unable to open file ' header_filename]);
            end
            
            try
                % Reads in the meta header data: meta_header_data{1} are the field names,
                % meta_header_data{2} are the values
                meta_header_data = strtrim(textscan(file_id, '%s %s', 'delimiter', '='));
            catch exc
                fclose(file_id);
                meta_header = [];
                return;
            end
            fclose(file_id);
            
            meta_header = [];
            
            data_filename_index = find(ismember(meta_header_data{1}, 'ElementDataFile'));
            if ~isempty(data_filename_index)
                values_array = meta_header_data{2};
                data_filename = values_array{data_filename_index};
                if strcmp(data_filename, 'LOCAL')
                    reporting.ShowWarning('PTKDiskUtilities:LocalDataNotSupported', 'PTK does not currently support image files with data embedded in the same file as the metaheader.');
                    meta_header = [];
                    return;
                end
            end
            
            
            for index = 1 : length(meta_header_data{1});
                meta_header.(genvarname(meta_header_data{1}{index})) = meta_header_data{2}{index};
            end
        end
        
        function [image_type, principal_filename, secondary_filenames] = GuessFileType(image_path, image_filename, default_guess, reporting)
            [~, name, ext] = fileparts(image_filename);
            if strcmp(ext, '.mat')
                image_type = PTKImageFileFormat.Matlab;
                principal_filename = {image_filename};
                secondary_filenames = {};
                return;

            % For metaheader files (mhd/mha) we also fetch the filename of the
            % raw image data
            elseif strcmp(ext, '.mhd') || strcmp(ext, '.mha')
                image_type = PTKImageFileFormat.Metaheader;
                [is_meta_header, raw_filename] = PTKDiskUtilities.IsFileMetaHeader(fullfile(image_path, image_filename), reporting);
                if ~is_meta_header
                    reporting.Error('PTKDiskUtilities:OpenMHDFileFailed', ['Unable to read metaheader file ' image_filename]);
                end
                principal_filename = {image_filename};
                secondary_filenames = {raw_filename};
                return;
                
            % If a .raw file is selected, look for the corresponding .mha or
            % .mhd file. We thrown an exception if no file is found, it cannot
            % be loaded or the raw filename does not match the raw file we are
            % loading
            elseif strcmp(ext, '.raw')
                [principal_filename, secondary_filenames] = PTKDiskUtilities.GetHeaderFileFromRawFile(image_path, name, reporting);
                if isempty(principal_filename)
                    reporting.ShowWarning('PTKDiskUtilities:HeaderFileLoadError', ['Unable to find valid header file for ' fullfile(image_path, image_filename)], []);
                else
                    if ~strcmp(secondary_filenames{1}, image_filename)
                        reporting.Error('PTKDiskUtilities:MetaHeaderRawFileMismatch', ['Mismatch between specified image filename and entry in ' principal_filename{1}]);
                    end
                    image_type = PTKImageFileFormat.Metaheader;
                    return;
                end
            end

            % Unknown file type. Try looking for a header file
            [principal_filename_mh, secondary_filenames_mh] = PTKDiskUtilities.GetHeaderFileFromRawFile(image_path, name, reporting);
            if (~isempty(principal_filename_mh)) && (strcmp(secondary_filenames_mh{1}, image_filename))
                image_type = PTKImageFileFormat.Metaheader;
                principal_filename = principal_filename_mh;
                secondary_filenames = secondary_filenames_mh;
                return;
            end
            
            % Test for a DICOM image
            if PTKDicomUtilities.IsDicom(image_path, image_filename)
                image_type = PTKImageFileFormat.Dicom;
                principal_filename = {image_filename};
                secondary_filenames = {};
                return;
            end

            % If all else fails, use the guess
            image_type = default_guess;
            principal_filename = {image_filename};
            secondary_filenames = {};
        end
        
        function [principal_filename, secondary_filenames] = GetHeaderFileFromRawFile(image_path, image_filename, reporting)
            [~, name, ~] = fileparts(image_filename);
            if exist(fullfile(image_path, [name '.mha']), 'file')
                header_filename = [name '.mha'];
            elseif exist(fullfile(image_path, [name '.mhd']), 'file')
                header_filename = [name '.mhd'];
            else
                principal_filename = {};
                secondary_filenames = {};
                return;
            end
            
            [is_meta_header, raw_filename] = PTKDiskUtilities.IsFileMetaHeader(fullfile(image_path, header_filename), reporting);
            if ~is_meta_header
                principal_filename = {};
                secondary_filenames = {};
                return;
            end
            principal_filename = {header_filename};
            secondary_filenames = {raw_filename};
        end
        
        function list_of_test_classes = GetListOfClassFiles(directory, superclass_name)
            % Returns a list of Matlab classes found in the specified directory which
            % inherit from the given superclass
            
            list_of_test_classes = {};
            list_of_files = PTKDiskUtilities.GetDirectoryFileList(directory, '*.m');
            for file_name = list_of_files
                [~, this_class_name, ~] = fileparts(file_name{1});
                if ~strcmp(this_class_name, superclass_name) && exist(this_class_name, 'class')
                    meta_class = meta.class.fromName(this_class_name);
                    superclasses = meta_class.SuperclassList;
                    if ~isempty(superclasses);
                        superclass_names = superclasses.Name;
                        if ismember(superclass_names, superclass_name, 'rows')
                            list_of_test_classes{end + 1} = this_class_name;
                        end
                    end
                end
            end
        end

        function Save(filename, value) %#ok<INUSD>
            save(filename, '-struct', 'value', '-v7');
        end
        
        function value = Load(filename) %#ok<INUSD>
            value = load(filename, '-mat');
        end
        
        function result = SaveStructure(file_path, filename_base, result, reporting)
            result = PTKDiskUtilities.ConvertStructAndSaveRawImageData(result, file_path, filename_base, 0, reporting);

            filename = [fullfile(file_path, filename_base) '.mat'];
            PTKDiskUtilities.Save(filename, result);
        end

        function results = LoadStructure(file_path, filename_base, reporting)
            filename = [fullfile(file_path, filename_base) '.mat'];
            results_struct = PTKDiskUtilities.Load(filename);
            results = PTKDiskUtilities.ConvertStructAndLoadRawImageData(results_struct, file_path, filename_base, reporting);
        end
        
        function [new_structure, next_index] = ConvertStructAndSaveRawImageData(old_structure, file_path, filename_base, next_index, reporting)
            if isstruct(old_structure)
                field_names = fieldnames(old_structure);
                for field = field_names'
                    field_name = field{1};
                    [new_structure.(field_name), next_index] = PTKDiskUtilities.ConvertStructAndSaveRawImageData(old_structure.(field_name), file_path, filename_base, next_index, reporting);
                end
            else
                if isa(old_structure, 'PTKImage')
                    reporting.LogVerbose(['Saving raw image data for ' filename_base]);
                    if next_index == 0
                        file_suffix = '';
                    else
                        file_suffix = ['_' int2str(next_index)];
                    end
                    raw_image_file_name = [filename_base file_suffix];
                    header = old_structure.SaveRawImage(file_path, raw_image_file_name, reporting);
                    next_index = next_index + 1;
                    new_structure = header;
                else
                    new_structure = old_structure;
                end
            end
        end
        
        function new_structure = ConvertStructAndLoadRawImageData(old_structure, file_path, filename_base, reporting)
            if isstruct(old_structure)
                field_names = fieldnames(old_structure);
                for field = field_names'
                    field_name = field{1};
                    new_structure.(field_name) = PTKDiskUtilities.ConvertStructAndLoadRawImageData(old_structure.(field_name), file_path, filename_base, reporting);
                end
            else
                new_structure = old_structure;
                if isa(old_structure, 'PTKImage')
                    old_structure.LoadRawImage(file_path, reporting);
                end
            end
        end
        
        function dir = GetDirectoryForFile(filename, reporting)
            exist_result = exist(filename, 'file');
            
            if exist_result == 0
                % Directory does not exist
                reporting.Error('PTKDiskUtilities:DirectoryDoesNotExist', 'The directory passed to PTKDiskUtilities.GetDirectoryForFile() does not exist.');
            
            elseif exist_result == 7
                % Directory specified
                dir = filename;
                
            elseif exist_result == 2
                % File specified - try to extract a directory
                [dir_path, ~, ~] = fileparts(filename);
                exist_result_2 = exist(dir_path, 'file');
                if exist_result_2 ~= 0
                    reporting.Error('PTKDiskUtilities:DirectoryDoesNotExist', 'The argument passed to PTKDiskUtilities.GetDirectoryForFile() does not exist or is not a directory.');
                else
                    dir = dir_path;
                end
            end
        end
        
        function filename_set = FilenameSetDiff(filename_set, filenames_to_match, match_path)
            if ~iscell(filenames_to_match)
                filenames_to_match = {filenames_to_match};
            end
            file_set = PTKContainerUtilities.GetFieldValuesFromSet(filename_set, 'Name');
            path_set = PTKContainerUtilities.GetFieldValuesFromSet(filename_set, 'Path');

            matching_files = false(1, numel(file_set));
            
            for match = filenames_to_match
                matching_files = matching_files & strcmp(file_set, match);
                matching_files = matching_files & strcmp(path_set, match_path);
            end
            
            filename_set = filename_set(~matching_files);
        end
        
        function SaveFigure(figure_handle, figure_filename)
            resolution_dpi = 300;
            resolution_str = ['-r' num2str(resolution_dpi)];
            
            print(figure_handle, '-depsc2', resolution_str, figure_filename);   % Export to .eps
            print(figure_handle, '-dpng', resolution_str, figure_filename);     % Export .png
        end
        
        function SaveImageCapture(capture, file_name, save_type, reporting)
            reporting.ShowProgress('Exporting image');
            if isa(file_name, 'PTKFilename');
                file_name = file_name.FullFile;
            end
            switch save_type
                case 'tif'
                    imwrite(capture.cdata, file_name, 'tif');
                case 'jpg'
                    imwrite(capture.cdata, file_name, 'jpg', 'Quality', 70);
                otherwise
                    reporting.Error('PTKDiskUtilities:SaveImageCapture:UnknownImageType', ['SaveImageCapture() does not support the image type ', save_type]);
            end
            reporting.CompleteProgress;
        end
        
        function compression_supported = CompressionSupported(compression, data_type, reporting)
            compression_supported = true;
            
            switch compression
                case {[], ''}
                    return;
                    
                case 'png'
                    switch data_type
                        case {'int32', 'uint32', 'int64', 'uint64'}
                            compression_supported = false;
                            return;
                    end
                case {'tiff', 'deflate'}
                    switch data_type
                        case {'int32', 'uint32', 'int64', 'uint64'}
                            compression_supported = false;
                            return;
                    end
                otherwise
                    reporting.Error('PTKDiskUtilities:CompressionSupported:UnknownCompressionType', ['I do not recognise the compression types  ', compression]);
            end
            
        end
        
        function SavePatchFile(patch_object, filename, reporting)
            try
                value = [];
                value.patch = patch_object;
                PTKDiskUtilities.Save(filename, value);
            catch ex
                reporting.ErrorFromException('PTKDiskUtilities:FailedtoSavePatchFile', ['Unable to save PTK patch file ' filename], ex);
            end
        end
        
        function patch = LoadPatch(filename, reporting)
            try
                if exist(filename, 'file')
                    patch_struct = PTKDiskUtilities.Load(filename);
                    patch = patch_struct.patch;
                else
                    reporting.Error('PTKDiskUtilities:PatchFileNotFound', 'No patch file found.');
                    patch = [];
                end
                
            catch ex
                reporting.ErrorFromException('PTKDiskUtilities:FailedtoLoadPatchFile', ['Error when loading patch file ' filename '.'], ex);
            end
        end
        
    end
end

