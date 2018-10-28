classdef MYSaveVesselMask < PTKPlugin
    % MYSaveVesselMask. Plugin for saving vessel as a mask
    %     for each lung
    %
    %     This is a plugin for the Pulmonary Toolkit. Plugins can be run using 
    %     the gui, or through the interfaces provided by the Pulmonary Toolkit.
    %     See PTKPlugin.m for more information on how to run plugins.
    %
    %     Plugins should not be run directly from your code.
    %
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    
    properties
        ButtonText = 'Save Vessel <br>mask'
        ToolTip = 'Saves Vessel segmentation result as mask image'
        Category = 'Export'

        AllowResultsToBeCached = true
        AlwaysRunPlugin = true
        PluginType = 'ReplaceOverlay'
        HidePluginInDisplay = false
        FlattenPreviewImage = true
        PTKVersion = '1'
        ButtonWidth = 6
        ButtonHeight = 2
        GeneratePreview = false
    end
    
    methods (Static)
        function results = RunPlugin(dataset, reporting)
            reporting.ShowProgress('Save Vessel mask');
            Vessel_results = dataset.GetResult('PTKVesselness');
            threshold = dataset.GetResult('PTKThresholdLung');
            template_image = threshold.BlankCopy;
            Vessel_raw_image = 3*uint8(Vessel_results.RawImage > 5);
            full_Vessel_image = zeros(template_image.OriginalImageSize);
            image_size = template_image.ImageSize;
            start_crop = template_image.Origin;
            full_Vessel_image(start_crop(1):(start_crop(1)+image_size(1)-1),start_crop(2):(start_crop(2)+image_size(2)-1),...
                start_crop(3):(start_crop(3)+image_size(3)-1)) = Vessel_raw_image;
            % Get the saving path
            data_info=dataset.GetImageInfo;
            current_data_path=data_info.ImagePath;
            save_root_path = uigetdir(current_data_path, 'Select Directory to Save Vessel Mask');
            save_full_path=fullfile(save_root_path,'VesselMask');
            if ~exist(save_full_path)
                mkdir(save_full_path);
            end
            for i = 1:size(full_Vessel_image,3)
                current_image = full_Vessel_image(:,:,i);
                save_mask_path = fullfile(save_full_path,'VesselMask');
                save_image_name = strcat(save_mask_path,num2str(i),'.jpg');
                imwrite(current_image,save_image_name);
            end
            results = Vessel_results.Copy;
        end
        
        function results = GenerateImageFromResults(results, ~, ~)
            vesselness_raw = 3*uint8(results.RawImage > 5);
            results.ChangeRawImage(vesselness_raw);
            results.ImageType = PTKImageType.Colormap;
        end         
    end
end
