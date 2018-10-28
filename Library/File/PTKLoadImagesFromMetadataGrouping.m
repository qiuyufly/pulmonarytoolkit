function image_wrapper = PTKLoadImagesFromMetadataGrouping(metadata_grouping, reporting)
    % PTKLoadImagesFromMetadataGrouping. Loads metadata from a series of DICOM files
    %
    %     Syntax
    %     ------
    %
    %         image_volume = PTKLoadImagesFromMetadataGrouping(metadata_list, reporting)
    %
    %             image_volume        
    %
    %             metadata_list  a set of metadata structures
    %
    %
    %             reporting       A PTKReporting or implementor of the same interface,
    %                             for error and progress reporting. Create a PTKReporting
    %                             with no arguments to hide all reporting. If no
    %                             reporting object is specified then a default
    %                             reporting object with progress dialog is
    %                             created
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %        

    if nargin < 2
        reporting = PTKReportingDefault;
    end
    
    reporting.ShowProgress('Reading pixel data');
    reporting.UpdateProgressValue(0);

    image_wrapper = PTKWrapper;
    
    num_slices = length(metadata_grouping.Metadata);

    % Load image slice
    first_image_slice = PTKDicomUtilities.ReadDicomImageFromMetadata(metadata_grouping.Metadata{1}, reporting);

    % Pre-allocate image matrix
    size_i = metadata_grouping.Metadata{1}.Rows;
    size_j = metadata_grouping.Metadata{1}.Columns;
    size_k = num_slices;
    samples_per_pixel = metadata_grouping.Metadata{1}.SamplesPerPixel;
    
    % Pre-allocate image matrix
    data_type = whos('first_image_slice');
    data_type_class = data_type.class;
    if (strcmp(data_type_class, 'char'))
        reporting.ShowMessage('PTKLoadImagesFromMetadataList:SettingDatatypeToInt8', 'Char datatype detected. Setting to int8');
        data_type_class = 'int8';
    end
    image_wrapper.RawImage = zeros([size_i, size_j, size_k, samples_per_pixel], data_type_class);
    image_wrapper.RawImage(:, :, 1, :) = first_image_slice;
    
    for file_index = 2 : num_slices        
        PTKDicomUtilities.ReadDicomImageIntoWrapperFromMetadata(metadata_grouping.Metadata{file_index}, image_wrapper, file_index, reporting);
        reporting.UpdateProgressValue(round(100*(file_index)/num_slices));
    end
    
    reporting.CompleteProgress;
end