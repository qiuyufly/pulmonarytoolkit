classdef PTKDiskCacheItem < handle
    % PTKDiskCacheItem. Part of the internal framework of the Pulmonary Toolkit.
    %
    %     You should not use this class within your own code. It is intended to
    %     be used internally within the framework of the Pulmonary Toolkit.
    %
    %     Used to store a result along with its dependency information.
    %     This class is used by PTKDiskCache to store the result of a plugin, 
    %     along with its dependency information.
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %        
    
    properties (SetAccess = private)
        CacheInfo  % Information about a result such as its dependency list
        Result     % The result of a calculation
    end
    
    methods
        function obj = PTKDiskCacheItem(cache_item_info, result)
            obj.CacheInfo = cache_item_info;
            obj.Result = result;
        end
    end
    
end

