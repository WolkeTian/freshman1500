% dartel create template
%% initial spm
clc;close;clear;
direc = 'D:\Gene119\Niftis';
spm('Defaults','fMRI');
spm_jobman('initcfg');
% clear matlabbatch
%% prepare matlabbatch
fprintf('%-40s:', 'Preparing spm batch...');
rc1files = cellstr(spm_select('ExtFPListRec', direc, '^rc1.*\.nii$')); 

rc2files = cellstr(spm_select('ExtFPListRec', direc, '^rc2.*\.nii$'));

templates = cellstr(spm_select('FPListRec', direc, '^Template_.*.nii$'));
% acquire all existing dartel templates images

%% create batch
matlabbatch{1}.spm.tools.dartel.warp1.images = {
                                               rc1files
                                               rc2files
                                               }';

matlabbatch{1}.spm.tools.dartel.warp1.settings.rform = 0;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).rparam = [4 2 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).K = 0;

matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).template = templates(1);

matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).rparam = [2 1 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).K = 0;

matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).template = templates(2);

matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).rparam = [1 0.5 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).K = 1;

matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).template = templates(3);

matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).rparam = [0.5 0.25 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).K = 2;

matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).template = templates(4);

matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).K = 4;

matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).template = templates(5);

matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).K = 6;

matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).template = templates(6);

matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.lmreg = 0.01;
matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.cyc = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.its = 3;

%% excute batch
fprintf('%-40s:', 'Excutingg spm batch...');
tic;
spm_jobman('run',matlabbatch);
toc;
