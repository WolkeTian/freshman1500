clear;clc;close;

load sub_QC_lists

sourcefolder = 'F:\fMRI1500\Conn\conn_fMRI1500\results\firstlevel\V2V_01\';
zALFF3mm = dir([sourcefolder, 'rBETA_Subject*.nii']);
% zALFF3mm(sub_invalid_indexIn1087) = [];

% powerTemplate = 'Power_Neuron_264ROIs_Radius5_Mask.nii';
dosenTemplate = 'F:\fMRI1500\Conn\dosen160\Dosenbach_Science_160ROIs_Radius5_Mask.nii';

New_alff_files = cell(numel(sub_valid),1);
for i = 1:numel(sub_valid)
    subid = sub_valid(i,1);
    
    % extract power 264 ROI ALFF values
    Alff_file = fullfile(zALFF3mm(i,1).folder, zALFF3mm(i,1).name);
    % resize_img(Alff_file, [3,3,3], nan(2,3), 0); % resize alff (2*2*2 mm) to match power template (3*3*3 mm);
    New_alff_file = fullfile(zALFF3mm(i,1).folder, [zALFF3mm(i,1).name]);
    New_alff_files{i} = New_alff_file;
end
% 
% OutputFile = 'ttemp.txt';
% w_ExtractROITC(New_alff_files, dosenTemplate, 2, OutputFile); % 2 means Multi label in mask
% ValidSubs_alff = load(OutputFile);
% ValidSubs_alff = ValidSubs_alff(2:end,:); % extract 264 ROIs' mean ALFFs
x = extract_value_atlas(New_alff_files, dosenTemplate);

