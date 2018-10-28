function convert_dicom_to_jpg(varargin)
read_root_path='/hpc/yzha947/Shabnam-IPFsubjects/IPF4(DUNDASS)/SE000001';
save_root_path='/hpc/yzha947/Shabnam-IPFsubjects/IPF4(DUNDASS)/SE000001/jpg'
read_full_path=fullfile(read_root_path,'CT000000');
F=dicomread(read_full_path);
F=uint8(255 * mat2gray(F));
save_full_path=fullfile(save_root_path,strcat('raw0000','.jpg'));
imwrite(F,save_full_path,'jpg');

for i=1:9
    read_full_path=fullfile(read_root_path,strcat('CT00000',num2str(i)));
    F=dicomread(read_full_path);
    F=uint8(255 * mat2gray(F));
    save_full_path=fullfile(save_root_path,strcat('raw000',num2str(i),'.jpg'));
    imwrite(F,save_full_path,'jpg');
end
for i=10:99
    read_full_path=fullfile(read_root_path,strcat('CT0000',num2str(i)));
    F=dicomread(read_full_path);
    F=uint8(255 * mat2gray(F));
    save_full_path=fullfile(save_root_path,strcat('raw00',num2str(i),'.jpg'));
    imwrite(F,save_full_path,'jpg');
end
for i=100:133
    read_full_path=fullfile(read_root_path,strcat('CT000',num2str(i)));
    F=dicomread(read_full_path);
    F=uint8(255 * mat2gray(F));
    save_full_path=fullfile(save_root_path,strcat('raw0',num2str(i),'.jpg'));
    imwrite(F,save_full_path,'jpg');
end