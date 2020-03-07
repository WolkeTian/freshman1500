%% initial spm
clc;close;clear;
direc = 'F:\fMRI1500\Niftis';
spm('Defaults','fMRI');
spm_jobman('initcfg');
% clear matlabbatch
%% unzip all fieldmap nii.gz files
% niigzs = spm_select('FPListRec', direc, '.*gre_field_mapping_2mm_rest.*\.nii\.gz$'); % ��ȡ���г�ͼ.nii.gz�ļ���·��
% niigzs = cellstr(niigzs);
% tic;cellfun(@gunzip, niigzs);toc;
% niigzs = spm_select('FPListRec', direc, '.*t1_mprage.*\.nii\.gz$'); % ��ȡ���нṹ��.nii.gz�ļ���·��
% niigzs = cellstr(niigzs);
% tic;cellfun(@gunzip, niigzs);toc;
%% parameters
% short TE:4.92ms; long TE:7.38; total readouttime = 29.9698;
% blip direction  = 1 (j,PA);

%% prepare matlabbatch
fprintf('%-40s:', 'Preparing spm batch...');
restfiles = cellstr(spm_select('ExtFPListRec', direc, '^a.*sms_bold_2mm.*\.nii$',Inf)); %  ��ȡʱ���У��������о�Ϣ̬.4d nii�ļ���·��(��������֡��

fmapfiles = cellstr(spm_select('ExtFPListRec', direc, '^2019.*gre_field_mapping_2mm_rest.*\.nii$')); % ��ȡ���г�ͼɨ��ɨ���ļ���·��
magfiles = fmapfiles(1:3:end); % ��ȡ��te magnitudeͼ��·��
phasefiles = fmapfiles(3:3:end); % ��ȡ��λ��ͼ��·��

% magfiles = cellstr(spm_select('ExtFPListRec', direc, '.*gre_field_mapping_2mm_rest.*e1\.nii$')); % ��ȡ��te magnitudeͼ��·��
% phasefiles = cellstr(spm_select('ExtFPListRec', direc, '.*gre_field_mapping_2mm_rest.*ph\.nii$')); % ��ȡ��λ��ͼ��·��
anatfiles = cellstr(spm_select('ExtFPListRec', direc, '.*t1_mprage.*\.nii$'));

%% create spm batch
for i = 1:numel(magfiles)
    subith_rests = restfiles((i*240 - 239):(i*240));
    subith_magfile = magfiles(i);
    subith_phasefile = phasefiles(i);
    subith_anatfile = anatfiles(i);
    % create vdm file batch
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase = subith_phasefile;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = subith_magfile;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.et = [4.92 7.38];
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.maskbrain = 1;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.blipdir = 1;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = 29.9698;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.epifm = 0;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.ajm = 0;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.method = 'Mark3D';
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.fwhm = 10;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.pad = 0;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.ws = 1;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.template = {'D:\matlabTools\spm12\toolbox\FieldMap\T1.nii'};
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.fwhm = 5;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.nerode = 2;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.ndilate = 4;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.thresh = 0.5;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.reg = 0.02;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.session.epi = subith_rests(1);
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.matchvdm = 1;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.sessname = 'session';
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped = 0;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.anat = '';
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 0;
    
end
%% ����batch�ļ�
save('filedmap.mat','matlabbatch');
%% excute matlabbatch

parpool
fprintf('%-40s:', 'Excutingg spm batch...');
tic;
parfor i = 1:numel(magfiles)
    try
        out{i} = spm_jobman('run',matlabbatch(i));
    catch
        out{i} = 'failed';
    end
end
toc;

%% ��25��������ʹ��magnitudeͼ����mask�����б�������������Ϊ0����mask������ʵ��Ӱ��
failed = cellfun(@(x) isequal(x,'failed'), out);
newbatch = matlabbatch(failed);
for i = 1:numel(newbatch)
    newbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.maskbrain = 0;
end

spm_jobman('run',newbatch);
    
    
%% realign & warp
clear matlabbatch
vdmfiles = cellstr(spm_select('ExtFPListRec', direc, '^vdm5.*\.nii$'));


%% spm batch
for i = 1:numel(magfiles)
    subith_rests = restfiles((i*240 - 239):(i*240));
    subith_vdm = vdmfiles(i);
    % realign & unwarp batch
    matlabbatch{i}.spm.spatial.realignunwarp.data.scans = subith_rests;
    matlabbatch{i}.spm.spatial.realignunwarp.data.pmscan(1) = subith_vdm;
    matlabbatch{i}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
    matlabbatch{i}.spm.spatial.realignunwarp.eoptions.sep = 4;
    matlabbatch{i}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
    matlabbatch{i}.spm.spatial.realignunwarp.eoptions.rtm = 0;
    matlabbatch{i}.spm.spatial.realignunwarp.eoptions.einterp = 2;
    matlabbatch{i}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
    matlabbatch{i}.spm.spatial.realignunwarp.eoptions.weight = '';
    matlabbatch{i}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
    matlabbatch{i}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
    matlabbatch{i}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
    matlabbatch{i}.spm.spatial.realignunwarp.uweoptions.jm = 0;
    matlabbatch{i}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
    matlabbatch{i}.spm.spatial.realignunwarp.uweoptions.sot = [];
    matlabbatch{i}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
    matlabbatch{i}.spm.spatial.realignunwarp.uweoptions.rem = 1;
    matlabbatch{i}.spm.spatial.realignunwarp.uweoptions.noi = 5;
    matlabbatch{i}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
    matlabbatch{i}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
    matlabbatch{i}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
    matlabbatch{i}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
    matlabbatch{i}.spm.spatial.realignunwarp.uwroptions.mask = 1;
    matlabbatch{i}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
end

save('realignunwarp.mat','matlabbatch');

%% 
tic;
parfor i = 1:numel(magfiles)
    try
        out2{i} = spm_jobman('run',matlabbatch(i));
    catch
        out2{i} = 'failed';
    end
end
toc;

% cellfun(@(x) isequal(x,'failed'), out2) % ����ʧ�ܱ���
