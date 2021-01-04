%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DCM2nii %%%%%%%%%%%%%%%%%%%%%%%%%%%
display('DCM2NII ing');
%%
clear;close;clc;
path = 'H:\'; % store path of raw dicoms 
topath = 'F:\fMRI1500\Niftis\'; %  store path of Niftis in BIDS format
tic;

%% prepration
% obtain subfolder names
folders = dir([path,'\SUB*']);
folders = struct2cell(folders);
names = folders(1,:)'; % cell of every subfolders' name
% 按照'_'切分，正确格式下SUB01736_JINDIE_01736切分为3个cell，然后取出末尾的被试编号
subids = cellfun(@(x) split(x,'_'),names,'UniformOutput', false); 
subids = cellfun(@(x) x{end}, subids, 'UniformOutput', false);

%% 开始转换需要的文件
parfor i = 1:numel(subids)
    if strcmp(subids{i}, '00646') || strcmp(subids{i}, '00170') % 两个数据不全的被试跳过
        continue
    else
        % 检查该被试nii文件是否已经存在
        %topath = 'F:\fMRI1500\Niftis\';
        totestpath = [topath, 'Sub', subids{i} ,'\fieldmap\rest2\*field*'];
        existdir = dir(totestpath);
               
        if numel(existdir) ~= 0
            disp(['sub', subids{i},'已转换,不在重复转换']);
            continue % 如果已经转换完成，则跳到下一个被试
        else
            disp(['sub', subids{i},'开始转换']);
            subpath = [path,'\',names{i}];
            child_dir = dir([subpath,'\SWU*']);
            child_fullpath = [child_dir(end,1).folder, '\', child_dir(end,1).name]; % 获取17个fmri文件的上级文件目录
            % obtain resting-state path
            rest_dir = dir([child_fullpath,'\*BOLD*REST*']);
            rest_fullpath = [rest_dir(end,1).folder,'\', rest_dir(end,1).name];
            % obtain resting-state fieldmaps path
            fmap_dir = dir([child_fullpath,'\*FIELD_MAPPING*REST*']);
            fmap1_fullpath = [fmap_dir(1,1).folder,'\', fmap_dir(1,1).name];
            fmap2_fullpath = [fmap_dir(2,1).folder,'\', fmap_dir(2,1).name];
            % obtain anat path
            t1_dir = dir([child_fullpath,'\T1_MPRAGE*']);
            t1_fullpath = [t1_dir(end,1).folder,'\', t1_dir(end,1).name];

            %% part of writting
            % create destination folder
            %topath = 'F:\fMRI1500\Niftis\';
            tosubpath = [topath, 'Sub', subids{i}];
            mkdir(tosubpath);
            torestpath = [tosubpath, '\', 'rest'];
            tot1path = [tosubpath, '\', 'anat'];
            tofmap1path = [tosubpath, '\', 'fieldmap\rest1'];
            tofmap2path = [tosubpath, '\', 'fieldmap\rest2'];
            
            cellfun(@(x) mkdir(x), {torestpath, tot1path, tofmap1path, tofmap2path});
            %cellfun(@(x) mkdir(x), {torestpath, tot1path, tofmap1path, tofmap2path, todwipath, todwifmap1path, todwifmap2path});
            % 开始转换至nifti格式
            % cmd格式: Dcm2niix路径  option 输出文件夹 文件名 输入文件夹
            % 如："D:\Programs\mricrogl\dcm2niix" -b y -z y -o E:\prisma_prep_data\dpabi_test\FunImg\sub01...
            % -f "%t_%p_%s" E:\prisma_prep_data\dpabi_test\FunRaw\sub01
            % convert rest-states images
            thecommand = ['"D:\Programs\mricrogl\dcm2niix" ', '-b y -z y -o ', torestpath, ' -f "%t_%p_%s" ', rest_fullpath];
            [~,~] = dos(thecommand); % [status,cmdout] = dos(command); 避免输出
             % convert anat images
            thecommand = ['"D:\Programs\mricrogl\dcm2niix" ', '-b y -z y -o ', tot1path, ' -f "%t_%p_%s" ', t1_fullpath];
            [~,~] = dos(thecommand);
            % convert filedmaps images
            thecommand = ['"D:\Programs\mricrogl\dcm2niix" ', '-b y -z y -o ', tofmap1path, ' -f "%t_%p_%s" ', fmap1_fullpath];
            [~,~] = dos(thecommand);
            thecommand = ['"D:\Programs\mricrogl\dcm2niix" ', '-b y -z y -o ', tofmap2path, ' -f "%t_%p_%s" ', fmap2_fullpath];
            [~,~] = dos(thecommand);

            % display successful information 
            disp(['Sub',subids{i},' converted successfully']);
        end
       
    end
       
end

toc;

%% Check if the number of converted files is normal
for i = 1:numel(subids)
    %if strcmp(subids{i}, '00646') || strcmp(subids{i}, '00170') % 两个数据不全的被试跳过
        %continue
    %else
        %topath = 'F:\fMRI1500\Niftis\';
        
        totestpath = [topath, 'Sub', subids{i} ,'\rest\*bold*'];
        existdir = dir(totestpath);
        if numel(existdir) ~= 2
            disp(['check ',subids{i},' rest num of files ']);
        end
        
        totestpath = [topath, 'Sub', subids{i} ,'\anat\*t1*'];
        existdir = dir(totestpath);
        if numel(existdir) ~= 2
            disp(['check ',subids{i},' anat num of files ']);
        end
        
        totestpath = [topath, 'Sub', subids{i} ,'\fieldmap\rest1\*field*'];
        existdir = dir(totestpath);
        if numel(existdir) ~= 4
            disp(['check ',subids{i},' fieldmap rest1 num of files ']);
        end
        
        totestpath = [topath, 'Sub', subids{i} ,'\fieldmap\rest2\*field*'];
        existdir = dir(totestpath);
        if numel(existdir) ~= 2
            disp(['check ',subids{i},' fieldmap rest2 num of files ']);
        end
        
    %end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% slice time %%%%%%%%%%%%%%%%%%%%%%%%%%%
display('Slice timing ing');
%%
% Initialise SPM
clc;close;clear;
direc = topath;
spm('Defaults','fMRI');
spm_jobman('initcfg');

% unzip all rest nii.gz files
 niigzs = spm_select('FPListRec', direc, '.*sms_bold_2mm.*\.nii\.gz$'); % obtain resting-state images path
 niigzs = cellstr(niigzs);
 tic;cellfun(@gunzip, niigzs);toc;

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
        out_a{i} = spm_jobman('run',matlabbatch(i))
    catch
        out_a{i} = 'failed';
    end
end
toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Realignment and fieldmap correction %%%%%%%%%%%%%%%%%%%%%%%%%%%
display('Realignment and fieldmap correction ing');
clear matlabbatch
%%

%% unzip all fieldmap nii.gz files
niigzs = spm_select('FPListRec', direc, '.*gre_field_mapping_2mm_rest.*\.nii\.gz$'); % 获取所有场图.nii.gz文件的路径
niigzs = cellstr(niigzs);
tic;cellfun(@gunzip, niigzs);toc;
niigzs = spm_select('FPListRec', direc, '.*t1_mprage.*\.nii\.gz$'); % 获取所有结构像.nii.gz文件的路径
niigzs = cellstr(niigzs);
tic;cellfun(@gunzip, niigzs);toc;
%% parameters
% short TE:4.92ms; long TE:7.38; total readouttime = 29.9698;
% blip direction  = 1 (j,PA);

%% prepare matlabbatch
fprintf('%-40s:', 'Preparing spm batch...');
restfiles = cellstr(spm_select('ExtFPListRec', direc, '^a.*sms_bold_2mm.*\.nii$',Inf)); %  获取时间层校正后的所有静息态.4d nii文件的路径(包含所有帧）

fmapfiles = cellstr(spm_select('ExtFPListRec', direc, '^20.*gre_field_mapping_2mm_rest.*\.nii$')); % 获取所有场图扫描扫描文件的路径
magfiles = fmapfiles(1:3:end); % 获取短te magnitude图的路径
phasefiles = fmapfiles(3:3:end); % 获取相位差图的路径

% magfiles = cellstr(spm_select('ExtFPListRec', direc, '.*gre_field_mapping_2mm_rest.*e1\.nii$')); % 获取短te magnitude图的路径
% phasefiles = cellstr(spm_select('ExtFPListRec', direc, '.*gre_field_mapping_2mm_rest.*ph\.nii$')); % 获取相位差图的路径
anatfiles = cellstr(spm_select('ExtFPListRec', direc, '.*t1_mprage.*\.nii$'));

display('Please check spm T1 template path');
spmT1_path = {'D:\matlabTools\spm12\toolbox\FieldMap\T1.nii'};
%pause;

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
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.maskbrain = 0;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.blipdir = 1;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = 29.9698;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.epifm = 0;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.ajm = 0;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.method = 'Mark3D';
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.fwhm = 10;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.pad = 0;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.ws = 1;
    matlabbatch{i}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.template = spmT1_path;
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
%% 储存batch文件
% save('filedmap.mat','matlabbatch');
%% excute matlabbatch

parpool
fprintf('%-40s:', 'Excutingg spm batch...');
tic;
parfor i = 1:numel(magfiles)
    try
        out_vdm{i} = spm_jobman('run',matlabbatch(i));
    catch
        out_vdm{i} = 'failed';
    end
end
toc;

    
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

% save('realignunwarp.mat','matlabbatch');

%% 
tic;
parfor i = 1:numel(magfiles)
    try
        out_u{i} = spm_jobman('run',matlabbatch(i));
    catch
        out_u{i} = 'failed';
    end
end
toc;

% cellfun(@(x) isequal(x,'failed'), out2) % 查找失败被试

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Coregister and segment anat files %%%%%%%%%%%%%%%%%%%%%%%%%%%
display('Coregister and segment anat files ing');
clear matlabbatch
%%

% coregister: Esitmate & segment (imported dartel)


%% prepare matlabbatch
fprintf('%-40s:', 'Preparing spm batch...');
meanrestfiles = cellstr(spm_select('ExtFPListRec', direc, '^meanua.*sms_bold_2mm.*\.nii$')); 


anatfiles = cellstr(spm_select('ExtFPListRec', direc, '.*t1_mprage.*\.nii$'));

spm_path = which('spm');
tpm_path = [spm_path(1:end-5), 'tpm\TPM.nii'];
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
    matlabbatch{i*2}.spm.spatial.preproc.tissue(1).tpm = {[tpm_path, ',1']};
    matlabbatch{i*2}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{i*2}.spm.spatial.preproc.tissue(1).native = [1 1]; % imported dartel rc1*.nii
    matlabbatch{i*2}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(2).tpm = {[tpm_path, ',2']};
    matlabbatch{i*2}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{i*2}.spm.spatial.preproc.tissue(2).native = [1 1]; % imported dartel rc2*.nii
    matlabbatch{i*2}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(3).tpm = {[tpm_path, ',3']};
    matlabbatch{i*2}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{i*2}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(4).tpm = {[tpm_path, ',4']};
    matlabbatch{i*2}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{i*2}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(5).tpm = {[tpm_path, ',5']};
    matlabbatch{i*2}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{i*2}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{i*2}.spm.spatial.preproc.tissue(6).tpm = {[tpm_path, ',6']};
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

% cellfun(@(x) isequal(x,'failed'), out_coreg) % find failed subject

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% dartel create template %%%%%%%%%%%%%%%%%%%%%%%%%%%
display('dartel create template ing');
clear matlabbatch
%%

%% prepare matlabbatch
fprintf('%-40s:', 'Preparing spm batch...');
rc1files = cellstr(spm_select('ExtFPListRec', direc, '^rc1.*\.nii$')); 


rc2files = cellstr(spm_select('ExtFPListRec', direc, '^rc2.*\.nii$'));

%% create batch
matlabbatch{1}.spm.tools.dartel.warp.images = {
                                               rc1files
                                               rc2files
                                               }';
matlabbatch{1}.spm.tools.dartel.warp.settings.template = 'Template';
matlabbatch{1}.spm.tools.dartel.warp.settings.rform = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).K = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).slam = 16;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).K = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).slam = 8;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).K = 1;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).slam = 4;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).K = 2;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).slam = 2;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).K = 4;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).slam = 1;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).K = 6;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its = 3;

%% excute batch
fprintf('%-40s:', 'Excutingg spm batch...');
tic;
spm_jobman('run',matlabbatch);
toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Normalise & smooth by dartel %%%%%%%%%%%%%%%%%%%%%%%%%%%
display('Normalise & smooth by dartel ing');
clear matlabbatch
%%

%% Normalise & smooth
% smooth kernel: 6 6 6
% original resolution: 2*2*2.3

%% prepare matlabbatch
fprintf('%-40s:', 'Preparing spm batch...');
flowfiles = cellstr(spm_select('FPListRec', direc, '^u_rc1.*\.nii$')); 
%  obtain all flow field images

restfiles = cellstr(spm_select('FPListRec', direc, '^ua20.*\.nii$'));
% obtain all relignmented resting-state images

templatefile = cellstr(spm_select('FPListRec', direc, '^Template_6.nii$'));


%% create batch

matlabbatch{1}.spm.tools.dartel.mni_norm.template = templatefile;
for i = 1:numel(flowfiles)
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(i).flowfield = flowfiles(i);
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(i).images = restfiles(i);
end

matlabbatch{1}.spm.tools.dartel.mni_norm.vox = [2 2 2]; % set to [2 2 2], near the original resolution;
matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                               NaN NaN NaN];
matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 0;
matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [6 6 6];

%save dartelNormal matlabbatch
%% excute batch
fprintf('%-40s:', 'Excutingg spm batch...');
tic;
spm_jobman('run',matlabbatch);
toc;
