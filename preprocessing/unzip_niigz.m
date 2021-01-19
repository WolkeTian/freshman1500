% Initialise SPM
clc;close;clear;
direc = 'F:\fMRI1500\Niftis';
spm('Defaults','fMRI');
spm_jobman('initcfg');

%% unzip all rest nii.gz files
niigzs = spm_select('FPListRec', direc, '.*\.nii\.gz$'); % obtain images path
niigzs = cellstr(niigzs);
tic;cellfun(@gunzip, niigzs);toc;
% tic;cellfun(@delete, niigzs);toc;
