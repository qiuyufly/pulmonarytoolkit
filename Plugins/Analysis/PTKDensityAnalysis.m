classdef PTKDensityAnalysis < PTKPlugin
    % PTKDensityAnalysis. Plugin for performing analysis of density
    %
    %     This is a plugin for the Pulmonary Toolkit. Plugins can be run using 
    %     the gui, or through the interfaces provided by the Pulmonary Toolkit.
    %     See PTKPlugin.m for more information on how to run plugins.
    %
    %     Plugins should not be run directly from your code.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2013.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %

    properties
        ButtonText = 'Density<br>analysis'
        ToolTip = 'Performs density analysis'
        Category = 'Analysis'

        Context = PTKContextSet.Any
        AllowResultsToBeCached = true
        AlwaysRunPlugin = false
        PluginType = 'DoNothing'
        HidePluginInDisplay = true
        FlattenPreviewImage = false
        PTKVersion = '2'
        ButtonWidth = 6
        ButtonHeight = 2
        GeneratePreview = false
    end
    
    methods (Static)
        function results = RunPlugin(dataset, context, reporting)
            
            % Get the density image
            roi = dataset.GetResult('PTKLungROI', PTKContext.LungROI);
            if ~roi.IsCT
                reporting.ShowMessage('PTKDensityAnalysis:NotCTImage', 'Cannot perform density analysis as this is not a CT image');
                return;
            end
            
            % Get a mask for the current region to analyse
            context_mask = dataset.GetTemplateMask(context);
            
            % Special case if this context doesn't exist for this dataset
            if isempty(context_mask) || ~context_mask.ImageExists
                results = PTKMetrics.empty;
                return;
            end
            
            % Create a region mask excluding the airways
            context_no_airways = dataset.GetResult('PTKGetMaskForContextExcludingAirways', context);
            
            % Reduce all images to a consistent size
            roi.ResizeToMatch(context_mask);
    
            results = PTKComputeAirTissueFraction(roi, context_mask, reporting);
            [emphysema_results, ~] = PTKComputeEmphysemaFromMask(roi, context_no_airways);
            results.Merge(emphysema_results);
            airway_metrics = dataset.GetResult('PTKAirwayAnalysis', context);
            if ~isempty(airway_metrics)
                results.Merge(airway_metrics, reporting);
            end
        end
    end
end