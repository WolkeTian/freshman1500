% check anat(segmented grey matter) & fun regsitration
%% initial spm
clc;close;clear;
direc = 'F:\fMRI1500\Niftis';
spm('Defaults','fMRI');
spm_jobman('initcfg');
% clear matlabbatch

%% prepare matlabbatch
fprintf('%-40s:', 'Preparing spm batch...');
meanrestfiles = cellstr(spm_select('ExtFPListRec', direc, '^meanua.*sms_bold_2mm.*\.nii$')); 
%  Obtain the average image of the data

gmfiles = cellstr(spm_select('ExtFPListRec', direc, '^c120.*t1_mprage.*\.nii$'));
%  Obtain all gray matter images

%% create batch
for i = 1:numel(anatfiles)
    
    matlabbatch{i}.spm.util.checkreg.data = {
                                         gmfiles{i};meanrestfiles{i}
                                         };
end

%% excute batch
fprintf('%-40s:', 'Excutingg spm batch...');
tic;
spm_jobman('run',matlabbatch);
toc;
