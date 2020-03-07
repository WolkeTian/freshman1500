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
%  获取时间层校正场图校正以及头动校正后的数据的平均图像

gmfiles = cellstr(spm_select('ExtFPListRec', direc, '^c120.*t1_mprage.*\.nii$'));
% 获取所有解剖图像

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