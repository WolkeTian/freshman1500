path = 'F:\fMRI1500\Conn\conn_fMRI1500\data\';
% Frame Global signal change > 5 (Z-value); Or Frame displacement > 0.9 mm
% scurb��������ݣ������޳�
cov_files = dir([path, 'COV_Subject*.mat']);
scrub_cells = cell(240,1);
for i = 1:numel(cov_files)
    load([path, cov_files(i,1).name]);
    scrub_cells{i,1} = data{1,3};
end

lengths = cellfun(@numel, scrub_cells) ./ 240;

histogram(lengths);

sublists = struct2cell(dir('F:\fMRI1500\Niftis\Sub*'));
sublists = sublists(1,:)';

% thred_Overscrub = prctile(lengths, 97); % scrub����ı��ԣ���97%��λ����
thred_Overscrub = 30; % scrub����ı��ԣ�����ʧ30��TR��1���ӣ�����
Subs_overscrub = sublists(lengths > thred_Overscrub);

%% get sub_invalid 168 people's index in 1087
% save sub_QC_lists subs_invalid sub_invalid_indexIn1087
sub_invalid_indexIn1087 = cell2mat(cellfun(@(x) find(strcmp(x, sublists)), subs_invalid, 'UniformOutput', false));
temp = ones(1,1087);
temp(sub_invalid_indexIn1087) = 0;