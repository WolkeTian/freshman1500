clear;close;clc;
path = 'H:\';
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
failed = [];
parfor i = 1:numel(subids)
        % 检查该被试nii文件是否已经存在
        topath = 'F:\fMRI1500\Niftis\';
        totestpath = [topath, 'Sub', subids{i} ,'\fieldmap\rest2\*field*'];
        existdir = dir(totestpath);
        try       
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
            fmap_dir = dir([child_fullpath,'\*FIELD*REST*']);
            fmap1_fullpath = [fmap_dir(1,1).folder,'\', fmap_dir(1,1).name];
            fmap2_fullpath = [fmap_dir(2,1).folder,'\', fmap_dir(2,1).name];
            % obtain anat path
            t1_dir = dir([child_fullpath,'\T1_MPRAGE*']);
            t1_fullpath = [t1_dir(end,1).folder,'\', t1_dir(end,1).name];
            
            % obtain dwi path
            dwi_dir = dir([child_fullpath,'\*DIFF_HARDI_00*']);
            dwi_fullpath = [dwi_dir(end,1).folder,'\', dwi_dir(end,1).name];
            % obtain dwi fieldmaps path
            fmap_dwi_dir = dir([child_fullpath,'\*FIELD*HARDI*']);
            fmap1_dwi_fullpath = [fmap_dwi_dir(1,1).folder,'\', fmap_dwi_dir(1,1).name];
            fmap2_dwi_fullpath = [fmap_dwi_dir(2,1).folder,'\', fmap_dwi_dir(2,1).name];

            %% part of writting
            % create destination folder
            topath = 'F:\fMRI1500\Niftis\';
            tosubpath = [topath, 'Sub', subids{i}];
            mkdir(tosubpath);
            torestpath = [tosubpath, '\', 'rest'];
            tot1path = [tosubpath, '\', 'anat'];
            tofmap1path = [tosubpath, '\', 'fieldmap\rest1'];
            tofmap2path = [tosubpath, '\', 'fieldmap\rest2'];
            todwipath = [tosubpath, '\', 'dwi'];
            todwifmap1path = [tosubpath, '\', 'fieldmap\dwi1'];
            todwifmap2path = [tosubpath, '\', 'fieldmap\dwi2'];

            mkdir(torestpath); mkdir(tot1path); mkdir(tofmap1path); mkdir(tofmap2path);
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
            
             % convert dwi images
            thecommand = ['"D:\Programs\mricrogl\dcm2niix" ', '-b y -z y -o ', todwipath, ' -f "%t_%p_%s" ', dwi_fullpath];
            [~,~] = dos(thecommand); % [status,cmdout] = dos(command); 避免输出
            % convert dwi filedmaps images
            thecommand = ['"D:\Programs\mricrogl\dcm2niix" ', '-b y -z y -o ', todwifmap1path, ' -f "%t_%p_%s" ', fmap1_dwi_fullpath];
            [~,~] = dos(thecommand);
            thecommand = ['"D:\Programs\mricrogl\dcm2niix" ', '-b y -z y -o ', todwifmap2path, ' -f "%t_%p_%s" ', fmap2_dwi_fullpath];
            [~,~] = dos(thecommand);

            % display successful information 
            disp(['Sub',subids{i},' converted successfully']);
        end
       catch
       failed = [failed,subids{i}];
       end
end

toc;

%% Check if the number of converted files is normal
for i = 1:numel(subids)
        topath = 'F:\fMRI1500\Niftis\';
        
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
end
