% coregister: Esitmate & segment (imported dartel)
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

anatfiles = cellstr(spm_select('ExtFPListRec', direc, '.*t1_mprage.*\.nii$'));
% 获取所有解剖图像

%% make batch
for i = 1:numel(anatfiles)
    % coregister: estimate
    matlabbatch{i*2-1}.spm.spatial.coreg.estimate.ref = meanrestfiles(i);
    matlabbatch{i*2-1}.spm.spatial.coreg.estimate.source = anatfiles(i);
    matlabbatch{i*2-1}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{i*2-1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{i*2-1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{i*2-1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{i*2-1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    
    % segment (enable dartel imported)
    matlabbatch{i*2}.spm.spatial.preproc.channel.vols = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{i*2 - 1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
    matlabbatch{i*2}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{i*2}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{i*2}.spm.spatial.preproc.channel.write = [0 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(1).tpm = {'D:\matlabTools\spm12\tpm\TPM.nii,1'};
    matlabbatch{i*2}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{i*2}.spm.spatial.preproc.tissue(1).native = [1 1]; % imported dartel rc1*.nii
    matlabbatch{i*2}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(2).tpm = {'D:\matlabTools\spm12\tpm\TPM.nii,2'};
    matlabbatch{i*2}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{i*2}.spm.spatial.preproc.tissue(2).native = [1 1]; % imported dartel rc2*.nii
    matlabbatch{i*2}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(3).tpm = {'D:\matlabTools\spm12\tpm\TPM.nii,3'};
    matlabbatch{i*2}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{i*2}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(4).tpm = {'D:\matlabTools\spm12\tpm\TPM.nii,4'};
    matlabbatch{i*2}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{i*2}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(5).tpm = {'D:\matlabTools\spm12\tpm\TPM.nii,5'};
    matlabbatch{i*2}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{i*2}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(6).tpm = {'D:\matlabTools\spm12\tpm\TPM.nii,6'};
    matlabbatch{i*2}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{i*2}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{i*2}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{i*2}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{i*2}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{i*2}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{i*2}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{i*2}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{i*2}.spm.spatial.preproc.warp.write = [0 1];
    matlabbatch{i*2}.spm.spatial.preproc.warp.vox = NaN;
    matlabbatch{i*2}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                                  NaN NaN NaN];
end

%% excute batch

fprintf('%-40s:', 'Excutingg spm batch...');
tic;
spm_jobman('run',matlabbatch);
toc;
% for i = 1:numel(anatfiles)
%     try
%         out_coreg{i} = spm_jobman('run',matlabbatch(2*i - 1));
%         out_seg{i} = spm_jobman('run',matlabbatch(2*i));
%     catch
%         out_coreg{i} = 'failed';
%         out_seg{i} = 'failed';
%     end
% end
% toc;

% cellfun(@(x) isequal(x,'failed'), out_coreg) % 查找失败被试