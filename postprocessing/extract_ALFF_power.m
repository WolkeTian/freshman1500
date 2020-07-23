clear;clc;close;

load sub_QC_lists

sourcefolder = 'F:\fMRI1500\Conn\conn_fMRI1500\results\firstlevel\V2V_01\';
zALFFs = dir([sourcefolder, 'BETA_Subject*.nii']);
zALFFs(sub_invalid_indexIn1087) = [];

powerTemplate = 'Power_Neuron_264ROIs_Radius5_Mask.nii';
ValidSubs_alff = zeros(numel(sub_valid), 264);

for i = 1:numel(sub_valid)
    subid = sub_valid(i,1);
    
    % extract power 264 ROI ALFF values
    Alff_file = fullfile(zALFFs(i,1).folder, zALFFs(i,1).name);
    resize_img(Alff_file, [3,3,3], nan(2,3), 0); % resize alff (2*2*2 mm) to match power template (3*3*3 mm);
    New_alff_file = fullfile(zALFFs(i,1).folder, ['r', zALFFs(i,1).name]);
    OutputFile = 'ttemp.txt';
    w_ExtractROITC(New_alff_file, powerTemplate, 2, OutputFile); % 2 means Multi label in mask
    mValues = load(OutputFile);
    mValues = mValues(2,:); % extract 264 ROIs' mean ALFFs
    ValidSubs_alff(i, :) = mValues;
end
