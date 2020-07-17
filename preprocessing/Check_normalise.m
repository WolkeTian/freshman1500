% check func normalise results
%% initial spm
clc;close;clear;
direc = 'F:\fMRI1500\Niftis';
spm('Defaults','fMRI');
spm_jobman('initcfg');
% clear matlabbatch

%% prepare matlabbatch
fprintf('%-40s:', 'Preparing spm batch...');
preprocessed = cellstr(spm_select('ExtFPListRec', direc, '^swua.*sms_bold_2mm.*\.nii$',1)); 
%  obtain all preprocessed images

gmfiles = cellstr(spm_select('ExtFPListRec', direc, '^c120.*t1_mprage.*\.nii$'));
% obtain all gray matter images

subfolders = dir('F:\fMRI1500\Niftis\Sub*');
topath = 'F:\fMRI1500\CheckNormalise\';
mkdir(topath);

%% create batch
for i = 1:numel(gmfiles)
    
    matlabbatch{i}.spm.util.checkreg.data = {
                                         preprocessed{i}
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
