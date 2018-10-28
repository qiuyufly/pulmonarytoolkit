classdef MYSaveAirwayMask < PTKPlugin
    % MYSaveLungMesh. Plugin for saving airway trees segmentation result as a mask
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
        ButtonText = 'Save airway <br>mask'
        ToolTip = 'Saves airway tree segmentation result as mask image'
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
            reporting.ShowProgress('Save airway mask');
            airway_results = dataset.GetResult('PTKAirways');
            threshold = dataset.GetResult('PTKThresholdLung');
            template_image = threshold.BlankCopy;
            results = PTKGetImageFromAirwayResults(airway_results.AirwayTree, template_image, false, reporting);
            airway_raw_image = results.RawImage;
            full_airway_image = zeros(template_image.OriginalImageSize);
            image_size = template_image.ImageSize;
            start_crop = template_image.Origin;
            full_airway_image(start_crop(1):(start_crop(1)+image_size(1)-1),start_crop(2):(start_crop(2)+image_size(2)-1),...
                start_crop(3):(start_crop(3)+image_size(3)-1)) = airway_raw_image;
%             % Rotate the airway segmented images (don't need to rotate for IPF subjects, 
%             % because we upside down the rawo image)
%             full_airway_image1 = full_airway_image;
%             for i = 1:image_size(3)
%                 full_airway_image(:,:,i) = full_airway_image1(:,:,(image_size(3)-i+1));
%             end
            % Get the saving path
            data_info=dataset.GetImageInfo;
            current_data_path=data_info.ImagePath;
            save_root_path = uigetdir(current_data_path, 'Select Directory to Save Airway Mask');
            save_full_path=fullfile(save_root_path,'PTKAirwayMask');
            if ~exist(save_full_path)
                mkdir(save_full_path);
            end
            for i = 1:size(full_airway_image,3)
                current_image = full_airway_image(:,:,i);
                save_mask_path = fullfile(save_full_path,'AirwayMask');
                if i-1<=9
                    save_image_name = strcat(save_mask_path,'000',num2str(i-1),'.jpg');
                elseif i-1>9&&i-1<=99
                    save_image_name = strcat(save_mask_path,'00',num2str(i-1),'.jpg');
                elseif i-1>99&&i-1<=999
                    save_image_name = strcat(save_mask_path,'0',num2str(i-1),'.jpg');
                end
                imwrite(current_image,save_image_name);
            end
        end
        
        function results = GenerateImageFromResults(results, image_templates, reporting)
        end        
    end
end
