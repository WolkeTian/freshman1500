%% Normalise & smooth
% smooth kernel: 6 6 6
% original resolution: 2*2*2.3
%% initial spm
clc;close;clear;
direc = 'F:\fMRI1500\Niftis';
spm('Defaults','fMRI');
spm_jobman('initcfg');
% clear matlabbatch
%% prepare matlabbatch
fprintf('%-40s:', 'Preparing spm batch...');
flowfiles = cellstr(spm_select('FPListRec', direc, '^u_rc1.*\.nii$')); 
%  获取时间层校正场图校正以及头动校正后的数据的平均图像

restfiles = cellstr(spm_select('FPListRec', direc, '^ua20.*\.nii$'));
% 获取所有解剖图像



%% create batch

matlabbatch{1}.spm.tools.dartel.mni_norm.template = {'F:\fMRI1500\Niftis\Sub00001\anat\Template_6.nii'};
for i = 1:numel(flowfiles)
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(i).flowfield = flowfiles(i);
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(i).images = restfiles(i);
end

matlabbatch{1}.spm.tools.dartel.mni_norm.vox = [2 2 2]; % set to [2 2 2], near the original resolution;
matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                               NaN NaN NaN];
matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 0;
matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [6 6 6];

save dartelNormal matlabbatch
%% excute batch
fprintf('%-40s:', 'Excutingg spm batch...');
tic;
spm_jobman('run',matlabbatch);
toc;