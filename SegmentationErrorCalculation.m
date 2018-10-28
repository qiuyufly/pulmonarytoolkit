% Calculate mean and RMS error between automatic segments and manual segments
clc;close;clear;
addpath('/hpc/yzha947/UsefulFiles/CommonFiles/matlab');
% The original setting (IPF)
subject_number = 'IPF001-H001';
root_path = '/hpc/yzha947/lung/Data/Human_IPF';
protocol = 'FRC';

% % The original setting (HLA)
% subject_number = 'P2BRP076-H1335';
% root_path = '/hpc/yzha947/lung/Data/Human_Lung_Atlas';
% protocol = 'FRC';

% Create file root
data_path = strcat(protocol,'/Lobe/AccuracyResult');
data_full_path = fullfile(root_path,subject_number,data_path);

% Read in error data
LO_error_filename = strcat(data_full_path,'/LOblique_DistanceDifference.exdata');
RH_error_filename = strcat(data_full_path,'/RHorizontal_DistanceDifference.exdata');
RO_error_filename = strcat(data_full_path,'/ROblique_DistanceDifference.exdata');

LO_data = extractInfoFromFiledExdata(LO_error_filename);
RH_data = extractInfoFromFiledExdata(RH_error_filename);
RO_data = extractInfoFromFiledExdata(RO_error_filename);

LO_error = LO_data(:,5);
RH_error = RH_data(:,5);
RO_error = RO_data(:,5);

% Calculate mean error
LO_mean = sum(LO_error)./length(LO_error)
RH_mean = sum(RH_error)./length(RH_error)
RO_mean = sum(RO_error)./length(RO_error)

% Calculate RMS error
LO_RMS = sqrt(sum(LO_error.^2)./length(LO_error))
RH_RMS = sqrt(sum(RH_error.^2)./length(RH_error))
RO_RMS = sqrt(sum(RO_error.^2)./length(RO_error))
