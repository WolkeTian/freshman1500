%% initial spm
clc;close;clear;
direc = 'F:\fMRI1500\Niftis';
spm('Defaults','fMRI');
spm_jobman('initcfg');
% clear matlabbatch
%% prepare matlabbatch
fprintf('%-40s:', 'Preparing spm batch...');
deformations = cellstr(spm_select('FPListRec', direc, '^y_20.*t1_mprage.*\.nii$')); 
%  获取所有原始变形场图像
gmfiles = cellstr(spm_select('ExtFPListRec', direc, '^c120.*t1_mprage.*\.nii$'));
wmfiles = cellstr(spm_select('ExtFPListRec', direc, '^c220.*t1_mprage.*\.nii$'));
csffiles = cellstr(spm_select('ExtFPListRec', direc, '^c320.*t1_mprage.*\.nii$'));
% 获取所有灰质/白质/脑脊液解剖图像

%% create batch
for i = 1:numel(gmfiles)
    
    matlabbatch{i}.spm.spatial.normalise.write.subj.def = deformations(i);
    matlabbatch{i}.spm.spatial.normalise.write.subj.resample = [gmfiles(i); wmfiles(i); csffiles(i)];
    matlabbatch{i}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                              78 76 85];
    matlabbatch{i}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
    matlabbatch{i}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{i}.spm.spatial.normalise.write.woptions.prefix = 'w';
end

%% excute batch
fprintf('%-40s:', 'Excutingg spm batch...');
parpool(5);
tic;
parfor i = 1:numel(gmfiles)
    try
        out{i} = spm_jobman('run',matlabbatch(i));
    catch
        out{i} = 'failed';
    end
end
toc;
