clear;close;clc;
PTKAddPaths;
ptk_main=PTKMain;
source_path='/hpc/yzha947/lung/Data/Human_Lung_Atlas/P2BRP076-H1335/FRC/Raw/P2BRP-076_BRP2-FRC22%-0.75--B31f_1768717';
file_infos=PTKDiskUtilities.GetListOfDicomFiles(source_path);
dataset=ptk_main.CreateDatasetFromInfo(file_infos);
lungs=dataset.GetResult('PTKLeftAndRightLungs');
DicomDataset=dataset.GetResult('PTKOriginalImage'); %% Get the raw PTKDicom data
[start_crop,end_crop]=MYGetLungROIForCT(DicomDataset); %% Get crop position
RawImage=DicomDataset.RawImage;
RawImage=RawImage(start_crop(1):end_crop(1), start_crop(2):end_crop(2), start_crop(3):end_crop(3));
DicomDataset.ChangeRawImage(RawImage);
%% Read in fissure fitted mesh data converted from CMISS
load('h1335_FRC_surfaceData.txt');

x=h1335_FRC_surfaceData(:,2);
y=h1335_FRC_surfaceData(:,3);
z=h1335_FRC_surfaceData(:,4);
x1=round(x/0.5371);y1=512-(round((0.5371*512-y)/0.5371));z1=round((-z)/0.5);
%% Get fissure line
FittedFissureMesh=zeros(512,512,736);
for i=1:length(x1)
    FittedFissureMesh(y1(i),x1(i),z1(i))=1;
end
FittedFissureMesh=FittedFissureMesh(start_crop(1):end_crop(1), start_crop(2):end_crop(2), start_crop(3):end_crop(3));
%% Separate the lobes
[a,b,c]=size(FittedFissureMesh);
SeparatedLobes=zeros(a,b,c);
for i=1:c
    for j=1:b
    list=FittedFissureMesh(:,j,i);
    [row,col]=find(list==1);
    if length(row)~=0
        SeparatedLobes(1:row,j,i)=5;
        SeparatedLobes((row+1):a,j,i)=6;
    end
    end
end
LungRawImage=lungs.RawImage;
SeparatedLobes=SeparatedLobes.*(LungRawImage~=0);
lobes=dataset.GetResult('PTKLobes');
PTKSeparatedLobes=lobes.Copy;
PTKSeparatedLobes.ChangeRawImage(SeparatedLobes);
FittedFissureMesh=FittedFissureMesh.*4;
PTKFittedFissureMesh=lungs.Copy;
PTKFittedFissureMesh.ChangeRawImage(FittedFissureMesh);
% FittedFissureMesh=uint16(FittedFissureMesh);