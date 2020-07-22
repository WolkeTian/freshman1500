clear;clc;close;
cd('F:\fMRI1500\Niftis');
todir = 'I:\fMRI1500_data';

sublist = dir('Sub*\');
rawT1s = dir('Sub*\anat\20*t1*nii');
prepedT1s = dir('Sub*\anat\smwc120*t1*nii');

rawFuncs = dir('Sub*\rest\20*rest*nii');
prepedFuncs = dir('Sub*\rest\swua20*rest*nii');
denoisedFuncs = dir('Sub*\rest\dswua20*rest*nii');
hmfiles = dir('Sub*\rest\*txt');
%% start to copy
tic;
for i = 1:numel(sublist)
    subid = sublist(i,1).name;
%     % copy raw T1 niftis
%     destination = [todir, '\Raw_T1\', subid, '\'];
%     mkdir(destination);
%     source = fullfile(rawT1s(i,1).folder, rawT1s(i,1).name);
%     copyfile(source, destination);
%     
%     % copy preprocessed T1 niftis
%     destination = [todir, '\Preprocessed_T1\', subid, '\'];
%     mkdir(destination);
%     source = fullfile(prepedT1s(i,1).folder, prepedT1s(i,1).name);
%     copyfile(source, destination);
%     
%     % copy raw Rest niftis
%     destination = [todir, '\Raw_Rest\', subid, '\'];
%     mkdir(destination);
%     source = fullfile(rawFuncs(i,1).folder, rawFuncs(i,1).name);
%     copyfile(source, destination);
%     
%     % copy preprocessed Rest niftis
%     destination = [todir, '\Preprocessed_Rest\', subid, '\'];
%     mkdir(destination);
%     source = fullfile(prepedFuncs(i,1).folder, prepedFuncs(i,1).name);
%     copyfile(source, destination);
    
    % copy preprocessed & denoised Rest niftis
    destination = [todir, '\Prep&Denoised_Rest\', subid, '\'];
    mkdir(destination);
    source = fullfile(denoisedFuncs(i,1).folder, denoisedFuncs(i,1).name);
    copyfile(source, destination);
    
    % copy headmotions
    destination = [todir, '\Headmotion\', subid, '\'];
    mkdir(destination);
    for j = 0:3
        source = fullfile(hmfiles(i*4 - j, 1).folder, hmfiles(i*4 - j, 1).name);
        copyfile(source, destination);
    end   
    
end

toc;

%% move alff files
sourcefolder = 'F:\fMRI1500\Conn\conn_fMRI1500\results\firstlevel\V2V_01\';
zALFFs = dir([sourcefolder, 'BETA_Subject*.nii']);

tic;
for i = 1:numel(sublist)
    subid = sublist(i,1).name;
    
    % copy preprocessed & denoised Rest niftis
    destination = [todir, '\zALFF\', 'zALFF_', subid, '.nii'];
    source = fullfile(zALFFs(i,1).folder, zALFFs(i,1).name);
    movefile(source, destination);

    
end
toc;
    
    




