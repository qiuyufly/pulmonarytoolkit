classdef MYOutputVesselData < PTKPlugin
    % MYOutputVeseelData. Plugin for output vessel segmentated data
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
        ButtonText = 'Output Vessel <br>Data'
        ToolTip = 'Output vessel segmented data'
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
            reporting.ShowProgress('Output vessel data');
            Vessel_results = dataset.GetResult('PTKVesselness');
            Vessel_raw_image = 3*uint8(Vessel_results.RawImage > 5);
            OriginalImageSize = Vessel_results.OriginalImageSize;
            VoxelSize = Vessel_results.VoxelSize;
            start_crop = Vessel_results.Origin;
            lungs = dataset.GetResult('PTKLeftAndRightLungs');
            
            vessel_index = find(Vessel_raw_image);
            lung_index_left = find(lungs.RawImage==2);
            lung_index_right = find(lungs.RawImage==1);
            
            % Get left and right vessel coords
            [if_member_left, index] = ismember(vessel_index, lung_index_left);
            [if_member_right, index] = ismember(vessel_index, lung_index_right);
            vessel_index_left = vessel_index(if_member_left);
            vessel_index_right = vessel_index(if_member_right);
            
            [x_left,y_left,z_left] = ind2sub(size(Vessel_raw_image),vessel_index_left);
            [x_right,y_right,z_right] = ind2sub(size(Vessel_raw_image),vessel_index_right);
            
            LeftLungCoor_x1=(y_left+start_crop(2)-1).*VoxelSize(2);
            LeftLungCoor_y1=OriginalImageSize(2).*VoxelSize(2)-(OriginalImageSize(1)-(x_left+start_crop(1)-1)).*VoxelSize(1);
            LeftLungCoor_z1=-(z_left+start_crop(3)-1).*VoxelSize(3);
            RightLungCoor_x1=(y_right+start_crop(2)-1).*VoxelSize(2);
            RightLungCoor_y1=OriginalImageSize(2).*VoxelSize(2)-(OriginalImageSize(1)-(x_right+start_crop(1)-1)).*VoxelSize(1);
            RightLungCoor_z1=-(z_right+start_crop(3)-1).*VoxelSize(3);
            
            LeftLungCoor = [LeftLungCoor_x1,LeftLungCoor_y1,LeftLungCoor_z1];
            RightLungCoor = [RightLungCoor_x1,RightLungCoor_y1,RightLungCoor_z1];
            
            % Get the saving path
            data_info=dataset.GetImageInfo;
            current_data_path=data_info.ImagePath;
            save_root_path = uigetdir(current_data_path, 'Select Directory to Save Lung Surface Points');
            save_full_path=fullfile(save_root_path,'PTKVessel');
            if ~exist(save_full_path)
                mkdir(save_full_path);
            end
            MYWriteExdata('vessel_Lefttrimmed.exdata',LeftLungCoor,'vessel_Left',0,save_full_path);
            offset = length(LeftLungCoor) +100;
            MYWriteExdata('vessel_Righttrimmed.exdata',RightLungCoor,'vessel_Right',offset,save_full_path);
            MYWriteIpdata('vessel_Lefttrimmed.ipdata',LeftLungCoor,'vessel_Left',0,save_full_path);
            MYWriteIpdata('vessel_Righttrimmed.ipdata',RightLungCoor,'vessel_Right',0,save_full_path);
            results = Vessel_results.Copy;
        end
        
        function results = GenerateImageFromResults(results, ~, ~)
            vesselness_raw = 3*uint8(results.RawImage > 5);
            results.ChangeRawImage(vesselness_raw);
            results.ImageType = PTKImageType.Colormap;
        end         
    end
end
