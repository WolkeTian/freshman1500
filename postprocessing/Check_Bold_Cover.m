%% check data integrity from extracted Power 264 ROI data (by conn)
path = 'F:\fMRI1500\Conn\conn_fMRI1500\data\';

power264_data = struct2cell(dir([path, 'ROI_Subject*.mat']));
power264_data = power264_data(1, :)';

%% check data integrity
isIncomplete = zeros(numel(power264_data), 1);

for i = 1:numel(power264_data)
    load([path, power264_data{i,1}]);
    subi_data = data(4:end); % The first 3 columns of data are GM WM CSF signals.
    % if there is invalid ROI data (std is 0), return 1.
    isIncomplete(i) = logical(sum(cellfun(@(x) (std(x) == 0), subi_data))); 
end

% get subject numbers
sublists = struct2cell(dir('F:\fMRI1500\Niftis\Sub*'));
sublists = sublists(1,:)';

subs_incomplete = sublists(logical(isIncomplete));
%% display subjects number with incomplete data
disp('The subjects with incomplete data are'); 
disp(subs_incomplete);