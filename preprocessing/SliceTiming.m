% Initialise SPM
clc;close;clear;
direc = 'F:\fMRI1500\Niftis';
spm('Defaults','fMRI');
spm_jobman('initcfg');

%% unzip all rest nii.gz files
% niigzs = spm_select('FPListRec', direc, '.*sms_bold_2mm.*\.nii\.gz$'); % obtain resting-state images path
% niigzs = cellstr(niigzs);
% tic;cellfun(@gunzip, niigzs);toc;

%% prepare matlabbatch
fprintf('%-40s:', 'Preparing spm batch...');
restfiles = spm_select('ExtFPListRec', direc, '.*sms_bold_2mm.*\.nii$',Inf); %  obtain resting-state nifti images path(including all frames）
restfiles = cellstr(restfiles);

jsonfiles = cellstr(spm_select('FPListRec', direc, '.*sms_bold_2mm.*\.json$')); % obtain resting-state json files path
slicetimes = cellfun(@readslicetimes, jsonfiles, 'UniformOutput', false);

for i = 1:numel(jsonfiles)
%     jsonpath = jsonfiles{i}; mesg = jsonpath(1:end-5);
%     disp(['The current processing file is ',mesg]); % facilitate to debug
    subith_rests = restfiles((i*240 - 239):(i*240));
    subith_stimes = slicetimes{i};
    %% spm batch
    matlabbatch{i}.spm.temporal.st.scans = {subith_rests};
    matlabbatch{i}.spm.temporal.st.nslices = numel(subith_stimes);
    matlabbatch{i}.spm.temporal.st.tr = 2;
    matlabbatch{i}.spm.temporal.st.ta = 0;
    matlabbatch{i}.spm.temporal.st.so = subith_stimes;
    matlabbatch{i}.spm.temporal.st.refslice = subith_stimes(1);
    matlabbatch{i}.spm.temporal.st.prefix = 'a';
end
% save batch file
% save('slicetiming.mat','matlabbatch');
%% excute matlabbatch
fprintf('%-40s:', 'Excutingg spm batch...');
tic;
parfor i = 1:numel(matlabbatch)
    try
        out{i} = spm_jobman('run',matlabbatch(i))
    catch
        out{i} = 'failed';
    end
end
toc;


function stimes = readslicetimes(filename)
    val = jsondecode(fileread(filename));
    stimes = val.SliceTiming; % unit to second
    stimes = stimes * 1000;
end
    
    
