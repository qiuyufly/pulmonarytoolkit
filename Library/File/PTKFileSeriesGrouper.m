classdef PTKFileSeriesGrouper < PTKBaseClass
    % PTKFileSeriesGrouper. Used to separate a Dicom images into series
    %
    %     PTKFileSeriesGrouper splits a series of Dicom images into 'bins' or 'groups'
    %     of images with the same image series UID. 
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2013.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %        

    
    properties (SetAccess = private)
        DicomSeriesGroupings
        NonDicomGrouping
    end
    
    methods
        function obj = PTKFileSeriesGrouper
            obj.DicomSeriesGroupings = containers.Map;
            obj.NonDicomGrouping = PTKFileSeriesGrouping([],[]);
        end
        
        % Adds a new image. If the metadata is coherent with an existing group,
        % we add the image to that group. Otherwise we create a new group.
        function AddFile(obj, uid, filename)
            if isempty(uid)
                obj.NonDicomGrouping.AddFile(filename);
            else
                if obj.DicomSeriesGroupings.isKey(uid)
                    group = obj.DicomSeriesGroupings(uid);
                    group.AddFile(filename);
                else
                    obj.DicomSeriesGroupings(uid) = PTKFileSeriesGrouping(uid, filename);
                end
            end
        end
        

        % Returns the number of groups in this data
        function number_of_groups = NumberOfDicomSeries(obj)
            number_of_groups = numel(obj.DicomSeriesGroupings);
        end
    end
end