function dicom_series = PTKGetDicomSeries(file_path, file_name, tags_to_get, reporting)
    % PTKGetDicomSeries. Gets the series UID for a Dicom file
    %
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2013.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %

    if nargin < 4
        reporting = PTKReportingDefault;
    end

    if isempty(tags_to_get)
        tags_to_get = PTKDicomDictionary.GroupingTagsDictionary(false);
    end

    try
        header = PTKReadDicomTags(file_path, file_name, tags_to_get, reporting);
    catch ex
        header = dicominfo(fullfile(file_path, file_name));
    end
    
    if isempty(header)
        dicom_series = [];
    else
        % If no SeriesInstanceUID tag then this is not a valid Dicom image (it
        % might be a DICOMDIR)
        if isfield(header, 'SeriesInstanceUID')
            dicom_series = header.SeriesInstanceUID;
        else
            dicom_series = [];
        end
    end
end