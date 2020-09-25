path = input("请输入文件路径,用引号+母文件夹路径，例如'F:\\10月10日扫描数据'");

% 'F:\test_chekmri'
cd(path)
folders = dir('SUB*');
temp = struct2cell(folders);
subfolders = temp(1,:);
temp = cellfun(@(x) strsplit(x, '_'), subfolders, 'UniformOutput', false);
temp = cell2mat(cellfun(@(x) str2double(x(end)), temp, 'UniformOutput', false)); % 转成数字

text = '本工具只检查影像文件数量是否正常；以及被试是否存在重复文件夹';
counts = hist(temp, unique(temp));
if sum(counts ~= 1) ~= 0
    message = ['被试编号 ',num2str(temp(counts ~= 1)), '存在多个数据文件夹，请检查'];
    disp(message);
    text =[text;message];
else
    message = ['检测到', num2str(numel(temp)),'名被试数据文件夹,', '被试编号包含', num2str(temp)];
    disp(message);
    text ={text;message};
    message = ['被试编号检查完毕，无重复'];
    text =[text;message];
    disp(message);
end




%% prepration
% 取出被试文件夹的文件名

%% 检查是否转换文件数量正常
theflag = ones(1,numel(temp));
for i = 1:numel(temp)
    x = dir([folders(i).name,'\SWU*']);
    if numel(x) == 1
        % 检查被试temp(i)的静息态
        imas = dir([folders(i).name,'\SWU*\SMS_BOLD_2MM_REST*\*IMA']);
        if numel(imas) ~=240
            message = ['被试编号 ',num2str(temp(i)), '，静息态文件数量不等于240，请检查'];
            disp(message);
            theflag(i) = 0;
            text =[text;message];
        end
        
        % 检查被试temp(i)的静息态场图
        imas = dir([folders(i).name,'\SWU*\GRE_FIELD_MAPPING_2MM_REST*\*IMA']);
        if numel(imas) ~= 186
            message = ['被试编号 ',num2str(temp(i)), '，静息态场图文件数量不等于186，请检查'];
            disp(message);
            theflag(i) = 0;
            text =[text;message];
        end
        
        % 检查被试temp(i)的结构像
        imas = dir([folders(i).name,'\SWU*\T1_MPRAGE_SAG_ISO*\*IMA']);
        if numel(imas) ~= 192
            message = ['被试编号 ',num2str(temp(i)), '，T1像文件数量不等于192，请检查'];
            disp(message);
            theflag(i) = 0;
            text =[text;message];
        end
        
        % 检查被试temp(i)的dwi
        imas = dir([folders(i).name,'\SWU*\SMS4_DIFF_HARDI_0*\*IMA']);
        if numel(imas) ~= 138
            message = ['被试编号 ',num2str(temp(i)), '，DTI文件数量不等于138，请检查'];
            disp(message);
            theflag(i) = 0;
            text =[text;message];
        end
        
        % 检查被试temp(i)的dwi场图
        imas = dir([folders(i).name,'\SWU*\SMS4_FIELDMAP_HARDI_*\*IMA']);
        if numel(imas) ~= 228
            message = ['被试编号 ',num2str(temp(i)), '，DTI场图文件数量不等于228，请检查'];
            disp(message);
            theflag(i) = 0;
            text =[text;message];
        end
    else
        message = ['被试编号 ',num2str(temp(i)), '次级目录文件夹数量不等于1，请检查'];
        disp(message);
        theflag(i) = 0;
        text =[text;message];
    end
end
if sum(theflag) == numel(temp)
    message = '被试影像文件数目检查完毕,未发现问题';
    disp(message);
    text =[text;message];
else
    message = '被试文件数目检查完毕,请根据提示检查';
    disp(message);
    text =[text;message];
end
timeprint = datestr(datetime);
fname = [timeprint(1:12), '影像文件检查信息.txt'];
writecell(text, fname);
disp('检查信息已写入目标文件夹下，请检查');
pause
% mcc -m checkMRI.m