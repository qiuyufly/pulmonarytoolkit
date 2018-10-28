clear;close;clc;
PTKAddPaths;
ptk_main=PTKMain;
% source_path='/hpc/yzha947/lung/Data/Human_Lung_Atlas/P2BRP076-H1335/FRC/Raw/P2BRP-076_BRP2-FRC22%-0.75--B31f_1768717';
source_path='/hpc/yzha947/2';
file_infos=PTKDiskUtilities.GetListOfDicomFiles(source_path);
dataset=ptk_main.CreateDatasetFromInfo(file_infos);
lungs=dataset.GetResult('PTKLeftAndRightLungs');

Lung=lungs.RawImage;
[a1,b1,c1]=size(Lung);
LeftLungCoor_x=[];RightLungCoor_x=[];
LeftLungCoor_y=[];RightLungCoor_y=[];
LeftLungCoor_z=[];RightLungCoor_z=[];
for i=1:2:c1
    AxLung=Lung(:,:,i);
    [RightRow,RightCol]=find(AxLung==1);
    MaxRightLung=max(RightCol);
    [LeftRow,LeftCol]=find(AxLung==2);
    MinLeftLung=min(LeftCol);
    LeftAndRightBoundry=round((MaxRightLung+MinLeftLung)./2);
    level=graythresh(AxLung);
    AxLung=im2bw(AxLung,level);
    AxLung=imfill(AxLung,'holes'); %% fill the holes
    AxLung=edge(AxLung,'canny'); %% extract the lung boundary
    Lung(:,:,i)=AxLung;
    for j=1:3:a1
        for k=(LeftAndRightBoundry+1):3:b1
            if Lung(j,k,i)~=0
                LeftLungCoor_x=[LeftLungCoor_x,j];
                LeftLungCoor_y=[LeftLungCoor_y,k];
                LeftLungCoor_z=[LeftLungCoor_z,i];
            end
        end
    end
    for j=1:3:a1
        for k=1:3:(LeftAndRightBoundry+1)
            if Lung(j,k,i)~=0
                RightLungCoor_x=[RightLungCoor_x,j];
                RightLungCoor_y=[RightLungCoor_y,k];
                RightLungCoor_z=[RightLungCoor_z,i];
            end
        end
    end
end

LungDicomImage = PTKLoadImages(dataset.GetImageInfo);
[start_crop,end_crop]=MYGetLungROIForCT(LungDicomImage); 

VoxelSize=lungs.VoxelSize;
OriginalImageSize=lungs.OriginalImageSize;
LeftLungCoor_x1=(LeftLungCoor_y+start_crop(2)-1).*VoxelSize(2);
LeftLungCoor_y1=OriginalImageSize(2).*VoxelSize(2)-(OriginalImageSize(1)-(LeftLungCoor_x+start_crop(1)-1)).*VoxelSize(1);
LeftLungCoor_z1=-(LeftLungCoor_z+start_crop(3)-1).*VoxelSize(3);
RightLungCoor_x1=(RightLungCoor_y+start_crop(2)-1).*VoxelSize(2);
RightLungCoor_y1=OriginalImageSize(2).*VoxelSize(2)-(OriginalImageSize(1)-(RightLungCoor_x+start_crop(1)-1)).*VoxelSize(1);
RightLungCoor_z1=-(RightLungCoor_z+start_crop(3)-1).*VoxelSize(3);

LeftLungCoor=[LeftLungCoor_x1',LeftLungCoor_y1',LeftLungCoor_z1'];
RightLungCoor=[RightLungCoor_x1',RightLungCoor_y1',RightLungCoor_z1'];
writeExdata('2.exdata',LeftLungCoor,'LeftLung',0);
writeExdata('2.exdata',RightLungCoor,'RightLung',200000);
                
                
