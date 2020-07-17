% check anat(segmented grey matter) & fun regsitration
%% initial spm
clc;close;clear;
direc = 'F:\fMRI1500\Niftis';
spm('Defaults','fMRI');
spm_jobman('initcfg');
% clear matlabbatch

%% prepare matlabbatch
fprintf('%-40s:', 'Preparing spm batch...');
rawimages = cellstr(spm_select('ExtFPListRec', direc, '^20.*sms_bold_2mm.*\.nii$',1)); 
%  obtain all func images path
gmfiles = cellstr(spm_select('ExtFPListRec', direc, '^c120.*t1_mprage.*\.nii$'));
% obtain all anat images path

subfolders = dir('F:\fMRI1500\Niftis\Sub*');
topath = 'F:\fMRI1500\CheckRawNifti\';
mkdir(topath);

%% create batch
for i = 1:numel(gmfiles)
    
    matlabbatch{i}.spm.util.checkreg.data = {
                                         rawimages{i}
                                         };
   
end

%% excute batch
fprintf('%-40s:', 'Excutingg spm batch...');
tic;
for i = 1:numel(gmfiles)
    spm_jobman('run',matlabbatch(i));
    temp = gcf;
    fname = subfolders(i).name;
    destination = [topath,'\',fname, '.jpg'];
    saveas(temp, destination);
end
toc;
