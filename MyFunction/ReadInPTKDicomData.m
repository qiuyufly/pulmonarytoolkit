%% This function used to read in PTKDicom format data
ptk_main=PTKMain;
source_path='/hpc/yzha947/lung/Data/Human_Lung_Atlas/P2BRP242-H11303/FRC/Raw/Dicom';
file_infos=PTKDiskUtilities.GetListOfDicomFiles(source_path);
dataset=ptk_main.CreateDatasetFromInfo(file_infos);
lungs=dataset.GetResult('PTKLeftAndRightLungs');
DicomDataset=dataset.GetResult('PTKOriginalImage'); %% Get the raw PTKDicom data
DicomDataset.ChangeRawImage(LobeDataMatrix);