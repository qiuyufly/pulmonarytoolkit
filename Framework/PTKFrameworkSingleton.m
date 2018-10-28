classdef (Sealed) PTKFrameworkSingleton < handle
    % PTKFrameworkSingleton. The singleton used by all instances of PTKMain
    %
    %     You should not use this class within your own code. It is intended to
    %     be used internally within the Pulmonary Toolkit.
    %
    %     Some parts of the PTK framework (such as the image database) rely on
    %     in-memory caches. Typically changes will be written to disk when the
    %     caches change, but they will not be reloaded at each operation for
    %     efficiency reasons. This would cause inconsistencies if multiple instances
    %     of these classes were running simultaneously.
    %
    %     To prevent this, cached information is held in a singleton class which all
    %     instances of PTKMain get access to.
    %
    %     PTKFrameworkSingleton is a singleton. It cannot be created using the
    %     constructor; instead call PTKFrameworkSingleton.GetFrameworkSingleton;
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %    
    
    properties (Access = private)
        ImageDatabase      % Database of image files
        FrameworkCache     % Information about mex files which is cached on disk
        LinkedDatasetRecorder
        DatasetMemoryCache % Stores PTKDatasetDiskCache objects in memory
        LinkedDatasetChooserMemoryCache
    end
        
    methods (Static)
        function framework_singleton = GetFrameworkSingleton(reporting)
            persistent FrameworkSingleton
            if isempty(FrameworkSingleton) || ~isvalid(FrameworkSingleton)
                FrameworkSingleton = PTKFrameworkSingleton(reporting);
            end
            framework_singleton = FrameworkSingleton;
        end
    end
    
    methods
        function Recompile(obj, reporting)
            % Forces recompilation of mex files
            PTKCompileMexFiles(obj.FrameworkCache, true, reporting);
        end
        
        function RebuildDatabase(obj, reporting)
            obj.ImageDatabase.Rebuild([], true, reporting)
        end
    
        function AddToDatabase(obj, image_uid, reporting)
            
            % CreateDatasetFromInfo() can import new data, so we may need to add
            % to the image database
            if ~obj.ImageDatabase.SeriesExists(image_uid)
                obj.ImageDatabase.Rebuild({image_uid}, false, reporting);
            end
        end
        
        function ReportChangesToDatabase(obj)
            obj.ImageDatabase.ReportChangesToDatabase;
        end
        
        function series_info = GetSeriesInfo(obj, series_uid)
            series_info = obj.ImageDatabase.GetSeries(series_uid);
        end
        
        function SaveImageDatabase(obj, reporting)
            obj.ImageDatabase.SaveDatabase(reporting);
        end
        
        function uids = ImportData(obj, filename, reporting)
            uids = PTKImageImporter(filename, obj.ImageDatabase, reporting);
        end
        
        function image_database = GetImageDatabase(obj)
            image_database = obj.ImageDatabase;
        end
        
        function linked_recorder = GetLinkedDatasetRecorder(obj)
            linked_recorder = obj.LinkedDatasetRecorder;
        end
        
        function dataset_memory_cache = GetDatasetMemoryCache(obj)
            dataset_memory_cache = obj.DatasetMemoryCache;
        end
        
        function linked_recorder_memory_cache = GetLinkedDatasetChooserMemoryCache(obj)
            linked_recorder_memory_cache = obj.LinkedDatasetChooserMemoryCache;
        end
    end
    
    methods (Access = private)
        function obj = PTKFrameworkSingleton(reporting)
            obj.FrameworkCache = PTKFrameworkCache.LoadCache(reporting);
            obj.LinkedDatasetRecorder = PTKLinkedDatasetRecorder.Load(reporting);
            obj.DatasetMemoryCache = PTKDatasetMemoryCache;
            obj.LinkedDatasetChooserMemoryCache = PTKLinkedDatasetChooserMemoryCache(obj.LinkedDatasetRecorder);
            obj.ImageDatabase = PTKImageDatabase.LoadDatabase(reporting);
            obj.ImageDatabase.Rebuild([], false, reporting)
            PTKCompileMexFiles(obj.FrameworkCache, false, reporting);
        end
    end
    
end
