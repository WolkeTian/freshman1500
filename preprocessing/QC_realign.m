clear;close;clc;
tic;
%% prepare files path
path = 'F:\fMRI1500\Niftis';
cd(path);
rpfiles = dir([path, '\Sub0*\rest\rp_a*.txt']);
test = load(fullfile(rpfiles(1,1).folder, rpfiles(1,1).name));
[dima,dimb] = size(test); % acquire dimension number

% tomkdirs = {'FD_files';'FD_scrub_files';'FD_temporalmask_files';'Friston24_files'};
% cellfun(@mkdir, tomkdirs);
%% initialize variables to store
degreed_rps = zeros(numel(rpfiles), dima, dimb);
[max_abs_motions, max_FDs, mean_FDs] = deal(zeros(numel(rpfiles),1));
subids = cell(numel(rpfiles),1);

clear test dimb
%% load and convert units (radians to degrees)
for i = 1:numel(rpfiles)
    cd(rpfiles(i,1).folder);
    fname = rpfiles(i,1).name;
    subfolder = rpfiles(i,1).folder;
    subids{i} = subfolder(strfind(subfolder,'Sub0'): strfind(subfolder, '\rest') - 1);
    radians_rp = load(fname);
    differential = [zeros(1,6); diff(radians_rp)]; % first derivatives of motion
    HMP_1st = differential;
    writematrix(HMP_1st, 'MotionFristDerivatives.txt');
    %% Framewise displacement calculations
    % radians to millimeters, by calculating displacement on the surface of
    % a sphere of radius 50 mm; Power 2012.
    differential = [differential(:,1:3),differential(:,4:6).*50]; 
    FD = sum(abs(differential),2); % Framewise displacement (FD): sum absolute values of 6 displacement
%     FD_fname = ['FD_files\', 'FD_', fname];
    FD_fname = 'FrameDisplacement.txt';
    writematrix(FD, FD_fname); % fd值存储到文件
    [max_FDs(i), mean_FDs(i)] = deal(max(FD), mean(FD));
%     All_FDs(:,i) = FD;
    %% create scrub regressors for FD >= 0.5mm 
%     thrd = 0.5;
%     scrub_fname = ['FD_scrub_files\','FD_scrub_', num2str(thrd), 'mm_', fname];
%     toScrub = find(FD >= thrd);
%     if isempty(toScrub) % if no frame outlier
%         writematrix(toScrub, scrub_fname); % write null to file
%     else
%         regressors = zeros(dima, numel(toScrub));
%         % creat one column regressor for each outlier
%         for j = 1:numel(toScrub)
%             regressors(toScrub(j),j) = 1;
%         end
%         writematrix(regressors, scrub_fname); % write regressors to file
%     end
    
    %% create temporal mask for FD >= 0.5mm
%     mask_fname = ['FD_temporalmask_files\', 'FD_temporalmask_', num2str(thrd), 'mm_', fname];
%     tomask = FD >= thrd;
%     % mark also the frames 1 back and 2 forward from any marked frames
%     mask_back1 = [tomask(2:end);0]; mask_forward1 = [0;tomask(1:end-1)];mask_forward2 = [0;0;tomask(1:end-2)]; 
%     tempmask = tomask + mask_back1 + mask_forward2 + mask_forward1; 
%     tempmask = double(tempmask == 0);% adjust to binary
%     writematrix(tempmask, mask_fname);
%     
    
%     %% Friston 24 calculations [rp rp^2 rp(t-1) rp(t-1)^2]; Friston 1996; Power 2014.
% %     Friston_fname = ['Friston24_files\','Friston24_', fname];
%     Friston_fname = 'Friston24_Parameters.txt';
%     rp_back1 = [zeros(1,6); radians_rp(1:end - 1, :)];
%     Friston24 = [radians_rp, radians_rp .^ 2, rp_back1, rp_back1.^2];
%     writematrix(Friston24, Friston_fname);
    %% 24 headmotion parameters, [rp rp' rp^2  rp'^2]; Satterthwaite et al., 2013.
    HMP24_fname = 'Headmotionparameters24.txt';
    HMP24 = [radians_rp, HMP_1st, radians_rp .^2,HMP_1st .^2];
    writematrix(HMP24, HMP24_fname);
    %% maximum absolute headmotion calculations
    degreed_rp = [radians_rp(:,1:3),radians_rp(:,4:6).*(180/pi)]; % radians to degress
    max_abs_motions(i,1) = max(abs(degreed_rp(:))); % generate max headmotion, note there are +/- values
    
%     degreed_rps(i,:,:) = degreed_rp;
end

% histogram(max_motions);
% histogram(mean_FDs);

%% list subid by exclusion criterion
criterion = 2; % absolute motion > 2 mm or 2 degree
exclu_abs = subids(max_abs_motions > criterion);
% FD exclusions criterion, mean FD > 0.2mm, max FD > 5mm;
exclu_meanFD = subids(mean_FDs > 0.2);
exclu_maxFD = subids(max_FDs > 5);

Union_exclusions = unique([exclu_abs; exclu_meanFD; exclu_maxFD]);

% disp(exclusions);

% 约9.28%的数据点FD>=0.2, 1.4% FD>=0.5；

%% write some QA results to file
cd(rpfiles(1,1).folder); % save to first subject's folder
fname = 'HeadmotionQA.csv';
QAresults = table(subids, max_abs_motions, max_FDs, mean_FDs);
writetable(QAresults, fname);
toc;
