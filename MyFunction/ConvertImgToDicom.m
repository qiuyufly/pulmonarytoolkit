%% This function is used to convert .img .hdr to Dicom format

%% Get 3D image
Info=analyze75info('/hpc/yzha947/lung/Data/Human_Lung_Atlas/P2BRP076-H1335/FRC/Raw/P2BRP076-H1335.hdr');
Img=analyze75read(Info);
% Info=interfileinfo('/hpc/yzha947/lung/Data/Human_Lung_Atlas/P2BRP076-H1335/FRC/Raw/P2BRP076-H1335.hdr');
% Img=interfileread(Info);
%% Get the size of 3D Image
[m_height,m_width,m_Thick]=size(Img);
mkdir('/hpc/yzha947/lung/Data/Human_Lung_Atlas/P2BRP076-H1335/FRC/Raw/Dicom/');
ff='/hpc/yzha947/lung/Data/Human_Lung_Atlas/P2BRP076-H1335/FRC/Raw/Dicom/';
%% Write out the dicom files
for i=1:m_Thick
    ff1=[ff,int2str(i)];
    pp=Img(1:m_height,1:m_width,i);
    dicomwrite(pp,ff1);
end