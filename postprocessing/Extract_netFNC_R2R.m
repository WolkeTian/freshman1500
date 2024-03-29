%% load ROI-ROI correlation matrix (calculated with conn)
clear;clc;
%path = 'F:\fMRI_第三批804人\Results\power\';
path = 'F:\fMRI_第一批1113人\Results\dosen\';
load([path, 'FNC_matrix.mat']);
fncs = FNC_matrix;
subnums = size(fncs, 3);



%% extract connectivity and reorder
%Labelnames = importdata('F:\Power_Neuron_264ROIs_Radius5_Mask.txt');
Labelnames = importdata('F:\Dosenbach_Science_160ROIs_Radius5_Mask.txt');

labels = unique(Labelnames); % find network names
% PowerNets = struct(numel(labels), 1);
NewOrder = [];
nodesNums = [];
nodesNames = {};
nodesStartIndex = [];
for i = 1:numel(labels)
    % create struct to save every network's name and index in 264 ROIs
    PowerNets(i,1).name = labels(i);
    PowerNets(i,1).index = find(strcmp(labels{i}, Labelnames));
    NewOrder = [NewOrder; PowerNets(i,1).index]; % reorder by Network label
    nodesStartIndex = [nodesStartIndex, sum(nodesNums) + 1]; % 得到每个网络对应的起始index
        
    nodesNums = [nodesNums, numel(PowerNets(i,1).index)]; % 得到每个网络对应的节点数量
    
    nodesNames = [nodesNames;labels(i)];% 得到每个网络对应的名字
end
nodesEndIndex = nodesStartIndex + nodesNums - 1;
% NewMatrix = ConnMatrix(NewOrder, NewOrder, :);
NewMatrix = fncs(NewOrder, NewOrder, :);

meanMatrix = mean(NewMatrix, 3);

imagesc(meanMatrix); colormap jet; colorbar;
title('Mean Correlation Matrix');
% 更改坐标刻度值和标签
xticks(nodesStartIndex);
xtickangle(45);
xticklabels(nodesNames);

yticks(nodesStartIndex);
ytickangle(45);
yticklabels(nodesNames);

% save fig
saveas(gcf,'meanCorrelationMatrix.jpg');

%% Calculate mean connectivity within network
meanWithin_Nets = zeros(subnums, numel(labels));
for i = 1:numel(labels)
    withinMatrix = NewMatrix(nodesStartIndex(i) : nodesEndIndex(i), nodesStartIndex(i) : nodesEndIndex(i), :);
    withinMatrix(isnan(withinMatrix)) = [];
    withinMatrix = reshape(withinMatrix, nodesNums(i) * (nodesNums(i) - 1), subnums);
    meanWithin = mean(withinMatrix, 1)';
    PowerNets(i,1).within = meanWithin;
    meanWithin_Nets(:,i) = meanWithin;
end

%% Calculate mean connectivity between network
AllLabels = cell(numel(labels), numel(labels));
Allmeans = zeros(numel(labels), numel(labels), subnums);
for i = 1:numel(labels)
    for j = 1:numel(labels)
        % 提取第i个网络和第j个网络的连接矩阵
        labelij = [labels{i},' to ', labels{j}];
        AllLabels{i, j} = labelij;
        
        matrixij = NewMatrix(nodesStartIndex(i):nodesEndIndex(i), nodesStartIndex(j):nodesEndIndex(j), :);
        meanRij = mean(mean(matrixij), 2); % cal mean value; size is 1*1*919
        
        Allmeans(i,j, :) = meanRij; % get nets*nets*subnums mean correlation matrix
    end
end
% extract mean connectivity between network
index2d = logical(triu(ones(numel(labels), numel(labels)), 1)); % 2d 上三角索引
uniqueLabels = AllLabels(index2d)';

uniqueMeans = zeros(subnums, numel(uniqueLabels));
for m = 1:subnums
   submMeans = Allmeans(:, :, m); 
   Unique_submMeans = submMeans(index2d);
   uniqueMeans(m, :) = Unique_submMeans;
end

%% write 2 table
tabletitle = [labels',uniqueLabels];
tablecontent = [meanWithin_Nets, uniqueMeans];
tablecontent = num2cell(tablecontent);
table2write = cell2table(tablecontent, 'VariableNames', tabletitle);

writetable(table2write, 'meanNetworkConnectivity.xlsx');

