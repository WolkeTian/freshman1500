%% initial spm
clc;close;clear;
direc = 'F:\fMRI1500\Niftis';
spm('Defaults','fMRI');
spm_jobman('initcfg');
% clear matlabbatch
%% prepare matlabbatch
fprintf('%-40s:', 'Preparing spm batch...');
Template = cellstr(spm_select('FPListRec', direc, '^Template_6.nii$')); 
flowfields = cellstr(spm_select('FPListRec', direc, '^u_rc120.*t1_mprage.*\.nii$')); 
%  获取最终模板图像和所有原始变形场图像
gmfiles = cellstr(spm_select('FPListRec', direc, '^c120.*t1_mprage.*\.nii$'));
wmfiles = cellstr(spm_select('FPListRec', direc, '^c220.*t1_mprage.*\.nii$'));
csffiles = cellstr(spm_select('FPListRec', direc, '^c320.*t1_mprage.*\.nii$'));
% 获取所有灰质/白质/脑脊液解剖图像

%% create batch
matlabbatch{1}.spm.tools.dartel.mni_norm.template = Template;
matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields = flowfields;
matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images = {
                                                                  gmfiles;
                                                                  wmfiles;
                                                                  csffiles
                                                                  };
matlabbatch{1}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                                   NaN NaN NaN];
matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 1; % for VBM: Preserve Amount
matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [6 6 6];


%% excute batch
tic; out = spm_jobman('run',matlabbatch); toc;
