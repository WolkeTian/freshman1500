function resultmats = extract_value_atlas(files, atlas)
    atlas_3d = niftiread(atlas);
    atlas_2d = reshape(atlas_3d, numel(atlas_3d),1); % 拉成2维度n*1
    Roinums = max(atlas_2d);
    if ~isequal(class(files), 'cell')
        % 如果是单个文件
        resultmats = extract_meanvalue(files, atlas_2d);
    elseif isequal(class(files), 'cell')
        % 如果是cell胞体多个文件，分别提取
        resultmats = zeros(numel(files), Roinums);
        for j = 1:numel(files)
            resultmats(j,:) = extract_meanvalue(files{j}, atlas_2d);
        end
    end
end

function resultmat = extract_meanvalue(singlefile, atlas_2d)
   
    rawvalues_3d = niftiread(singlefile);
    rawvalues_2d = reshape(rawvalues_3d, numel(rawvalues_3d), 1); % 拉成2维
    assert(numel(rawvalues_2d) == numel(atlas_2d), 'Dimension unmatched!'); %判断维度是否一致
    Roinums = max(atlas_2d);
    ressets = zeros(1,Roinums);
    for i = 1:Roinums
        resvalues = mean(rawvalues_2d(atlas_2d == i)); % 计算均值
        ressets(i) = resvalues; % 赋到矩阵中
    end
    resultmat = ressets;
end
        
        