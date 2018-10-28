classdef MYViewPASSFissure < PTKPlugin
    % MYViewPASSFissure. Plugin for viewing each PASS lobe segmentation result in PTK viewer
    %
    %     This is a plugin for a self-built function of the Pulmonary Toolkit. Plugins can be run using
    %     the gui, or through the interfaces provided by the Pulmonary Toolkit.
    %     See PTKPlugin.m for more information on how to run plugins.
    %
    %     Plugins should not be run directly from your code.
    %
    %     PTKAirways calls the PTKTopOfTrachea plugin to find the trachea
    %     location, and then runs the library routine
    %     PTKAirwayRegionGrowingWithExplosionControl to obtain the
    %     airway segmentation. The results are stored in a heirarchical tree
    %     structure.
    %
    %     The output image generated by GenerateImageFromResults creates a
    %     colour-coded segmentation image with true airway points shown as blue
    %     and explosion points shown in red.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    properties
        ButtonText = 'View PASS Fissures'
        ToolTip = 'Shows lobe segmentation result of PASS'
        Category = 'Fissures'
        
        AllowResultsToBeCached = true
        AlwaysRunPlugin = false
        PluginType = 'ReplaceOverlay'
        HidePluginInDisplay = false
        FlattenPreviewImage = true
        PTKVersion = '1'
        ButtonWidth = 6
        ButtonHeight = 2
        GeneratePreview = true
        Visibility = 'Developer'
        
        EnableModes = PTKModes.EditMode
        SubMode = PTKSubModes.FixedBoundariesEditing
    end
    
    methods (Static)
        function results = RunPlugin(dataset,reporting)
            if nargin < 2
                reporting = PTKReportingDefault;
            end
            DicomDataset = dataset.GetResult('PTKOriginalImage');%% Get the raw PTKDicom data
            ImageSize = DicomDataset.ImageSize;
            row_num=ImageSize(1);col_num=ImageSize(2);sli_num=ImageSize(3);
            
            % Get PASS Lobe segmentation result
            data_info = dataset.GetImageInfo;
            current_data_path = data_info.ImagePath;
            PASS_lobe_path = uigetdir(current_data_path, 'Select Directory to Read in PASS Lobe Segmentation Result');
            if PASS_lobe_path == 0
                reporting.Error('MYViewPASSFissure:ProgramErro', 'Can not read in PASS lobe segmentation result');
            end
            
            PASS_lobe_mask_name = fullfile(PASS_lobe_path,'LobeSmooth.mask.mask.hdr');
            lobe_mask_info = analyze75info(PASS_lobe_mask_name);
            lobe_mask = analyze75read(lobe_mask_info);
            
            % Get PASS fissure lines
            LUL_matrix = zeros(row_num,col_num,sli_num); LLL_matrix = zeros(row_num,col_num,sli_num);
            RUL_matrix = zeros(row_num,col_num,sli_num); RML_matrix = zeros(row_num,col_num,sli_num);
            RLL_matrix = zeros(row_num,col_num,sli_num); RUML_matrix = zeros(row_num,col_num,sli_num);
            LO_fissure_maxtrix = zeros(row_num,col_num,sli_num);
            RO_fissure_maxtrix = zeros(row_num,col_num,sli_num);
            RH_fissure_maxtrix = zeros(row_num,col_num,sli_num);
            whole_fissure_matrix = zeros(row_num,col_num,sli_num);
            
            LUL_matrix(lobe_mask==14) = 1;LLL_matrix(lobe_mask==8) = 1;
            RUL_matrix(lobe_mask==20) = 1;RML_matrix(lobe_mask==23) = 1;
            RLL_matrix(lobe_mask==26) = 1;
            RUML_matrix(lobe_mask==20) = 1;RUML_matrix(lobe_mask==23) = 1;
            
            SE = ones(3,3,3);
            LUL_matrix = imdilate(LUL_matrix,SE);
            LLL_matrix = imdilate(LLL_matrix,SE);
            RUL_matrix = imdilate(RUL_matrix,SE);
            RML_matrix = imdilate(RML_matrix,SE);
            RLL_matrix = imdilate(RLL_matrix,SE);
            RUML_matrix = imdilate(RUML_matrix,SE);
            SE1 = ones(2,2,2);
            LO_fissure_maxtrix((LUL_matrix + LLL_matrix)==2) = 1;
            LO_fissure_maxtrix = imerode(LO_fissure_maxtrix,SE1).*4;
            RO_fissure_maxtrix((RLL_matrix + RUML_matrix)==2) = 1;
            RO_fissure_maxtrix = imerode(RO_fissure_maxtrix,SE1).*3;
            RH_fissure_maxtrix((RUL_matrix + RML_matrix)==2) = 1;
            RH_fissure_maxtrix = imerode(RH_fissure_maxtrix,SE1).*2;
            whole_fissure_matrix = LO_fissure_maxtrix+RO_fissure_maxtrix+RH_fissure_maxtrix;
            whole_fissure_matrix(whole_fissure_matrix==7) = 3;
            whole_fissure_matrix(whole_fissure_matrix==5) = 2;
            
            lungs = dataset.GetResult('PTKLeftAndRightLungs');
            results = lungs.Copy;
            [start_crop,end_crop] = MYGetLungROIForCT(DicomDataset);
            whole_fissure_matrix = whole_fissure_matrix(start_crop(1):end_crop(1),start_crop(2):end_crop(2),start_crop(3):end_crop(3));
            results.ChangeRawImage(whole_fissure_matrix);
        end
    end
end
