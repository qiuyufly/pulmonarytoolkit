clear;close;clc;
PTKAddPaths;
ptk_main=PTKMain;
source_path='/hpc/yzha947/lung/Data/Human_Lung_Atlas/P2BRP076-H1335/FRC/Raw/P2BRP-076_BRP2-FRC22%-0.75--B31f_1768717';
file_infos=PTKDiskUtilities.GetListOfDicomFiles(source_path);
dataset=ptk_main.CreateDatasetFromInfo(file_infos);
lungs=dataset.GetResult('PTKLeftAndRightLungs');
LungRawImage=lungs.RawImage;
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
for i=1:c
    [row,col]=find(FittedFissureMesh(:,:,i)==1);
    if length(row)~=0
    if length(row)<=9
    y1=polyfit(col,row,(length(row)-1));
    else
       y1=polyfit(col,row,9); 
    end
    end
    col_insert1=min(col);
    row_insert1=round(polyval(y1,col_insert1));
    if row_insert1>0
        while row_insert1>0&&col_insert1>0&&LungRawImage(row_insert1,col_insert1,i)~=0;
        FittedFissureMesh(row_insert1,col_insert1,i)=1;
        col_insert1=col_insert1-1;
        row_insert1=round(polyval(y1,col_insert1));
        end
    end
        col_insert2=max(col);
        row_insert2=round(polyval(y1,col_insert2));
        if row_insert2>0
            while row_insert2>0&&col_insert2>0&&LungRawImage(row_insert2,col_insert2,i)~=0;
            FittedFissureMesh(row_insert2,col_insert2,i)=1;
            col_insert2=col_insert2+1;
            row_insert2=round(polyval(y1,col_insert2));
            end
        end
end
SeparatedLobes=zeros(a,b,c);
for i=1:c
    for j=1:b
        list=FittedFissureMesh(:,j,i);
        [row1,col1]=find(list==1);
        if length(row1)~=0
            SeparatedLobes(1:row1,j,i)=5;
            SeparatedLobes((row1+1):a,j,i)=6;
        end
    end
        [row2,col2]=find(SeparatedLobes(:,:,i)==0&LungRawImage(:,:,i)~=0);
        [row3,col3]=find(FittedFissureMesh(:,:,i)==1);
        average_row=mean(row3);
        for k=1:length(row2)
            if row2(k)>=average_row
                SeparatedLobes(row2(k),col2(k),i)=6;
            else
                SeparatedLobes(row2(k),col2(k),i)=5;
            end
        end
end

SeparatedLobes=SeparatedLobes.*(LungRawImage~=0);
lobes=dataset.GetResult('PTKLobes');
PTKSeparatedLobes=lobes.Copy;
PTKSeparatedLobes.ChangeRawImage(SeparatedLobes);
FittedFissureMesh=FittedFissureMesh.*4;
PTKFittedFissureMesh=lungs.Copy;
PTKFittedFissureMesh.ChangeRawImage(FittedFissureMesh);
% FittedFissureMesh=uint16(FittedFissureMesh);