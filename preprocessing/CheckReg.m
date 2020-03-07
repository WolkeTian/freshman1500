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
%  ��ȡʱ���У����ͼУ���Լ�ͷ��У��������ݵ�ƽ��ͼ��

gmfiles = cellstr(spm_select('ExtFPListRec', direc, '^c120.*t1_mprage.*\.nii$'));
% ��ȡ���н���ͼ��

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