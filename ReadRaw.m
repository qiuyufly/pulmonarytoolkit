% clear;clc;close;
% row=512;col=512;sli=464;
% fin=fopen('lola11-01.raw','r');
% I=fread(fin,row*col*sli,'uint8=>uint8'); 
% Z=reshape(I,row,col,sli);
% Z=Z';
% k=imshow(Z)

clear;clc;close;
fid = fopen('lola11-01.mhd');
a= 1;
line = 0;
while line ~= -1
    line = fgetl(fid);
    data{a} = line;
    a = a +1;
end
fclose(fid);

%Read element spacing
idx1=cellfun(@(x) ~isempty( strfind(x, 'ElementSpacing') ), data);
line1=find(idx1,1);
spacing=str2num(data{line1}(18:length(data{line1})));

%Read dimension
idx2=cellfun(@(x) ~isempty( strfind(x, 'DimSize') ), data);
line2=find(idx2,1);
dimsize=str2num(data{line2}(11:length(data{line2})));

%Read dataType
idx4=cellfun(@(x) ~isempty( strfind(x, 'ElementType') ), data);
line4=find(idx4,1);
ElementType=data{line4}(15:length(data{line4}));

if strcmp(ElementType, 'MET_UCHAR')==1
    datatype='*uint8';
elseif strcmp(ElementType, 'MET_CHAR')==1
    datatype='*int8';
elseif strcmp(ElementType, 'MET_USHORT')==1
    datatype='*uint16';
elseif strcmp(ElementType, 'MET_SHORT')==1
    datatype='*int16';
else
    fprintf(1,'Unable to use data type: %s\n', ElementType);
end

%Read raw filename
idx3=cellfun(@(x) ~isempty( strfind(x, 'ElementDataFile') ), data);
line3=find(idx3,1);
rawfilename=data{line3}(19:length(data{line3}));

%Read raw file
[pathstr,name, ext]=fileparts('lola11-01.raw');
fid=fopen(strcat(pathstr, '/', rawfilename), 'r');
img=fread(fid,datatype);
fclose(fid);
img=reshape(img,dimsize(1),dimsize(2),dimsize(3));