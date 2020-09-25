path = input("�������ļ�·��,������+ĸ�ļ���·��������'F:\\10��10��ɨ������'");

% 'F:\test_chekmri'
cd(path)
folders = dir('SUB*');
temp = struct2cell(folders);
subfolders = temp(1,:);
temp = cellfun(@(x) strsplit(x, '_'), subfolders, 'UniformOutput', false);
temp = cell2mat(cellfun(@(x) str2double(x(end)), temp, 'UniformOutput', false)); % ת������

text = '������ֻ���Ӱ���ļ������Ƿ��������Լ������Ƿ�����ظ��ļ���';
counts = hist(temp, unique(temp));
if sum(counts ~= 1) ~= 0
    message = ['���Ա�� ',num2str(temp(counts ~= 1)), '���ڶ�������ļ��У�����'];
    disp(message);
    text =[text;message];
else
    message = ['��⵽', num2str(numel(temp)),'�����������ļ���,', '���Ա�Ű���', num2str(temp)];
    disp(message);
    text ={text;message};
    message = ['���Ա�ż����ϣ����ظ�'];
    text =[text;message];
    disp(message);
end




%% prepration
% ȡ�������ļ��е��ļ���

%% ����Ƿ�ת���ļ���������
theflag = ones(1,numel(temp));
for i = 1:numel(temp)
    x = dir([folders(i).name,'\SWU*']);
    if numel(x) == 1
        % ��鱻��temp(i)�ľ�Ϣ̬
        imas = dir([folders(i).name,'\SWU*\SMS_BOLD_2MM_REST*\*IMA']);
        if numel(imas) ~=240
            message = ['���Ա�� ',num2str(temp(i)), '����Ϣ̬�ļ�����������240������'];
            disp(message);
            theflag(i) = 0;
            text =[text;message];
        end
        
        % ��鱻��temp(i)�ľ�Ϣ̬��ͼ
        imas = dir([folders(i).name,'\SWU*\GRE_FIELD_MAPPING_2MM_REST*\*IMA']);
        if numel(imas) ~= 186
            message = ['���Ա�� ',num2str(temp(i)), '����Ϣ̬��ͼ�ļ�����������186������'];
            disp(message);
            theflag(i) = 0;
            text =[text;message];
        end
        
        % ��鱻��temp(i)�Ľṹ��
        imas = dir([folders(i).name,'\SWU*\T1_MPRAGE_SAG_ISO*\*IMA']);
        if numel(imas) ~= 192
            message = ['���Ա�� ',num2str(temp(i)), '��T1���ļ�����������192������'];
            disp(message);
            theflag(i) = 0;
            text =[text;message];
        end
        
        % ��鱻��temp(i)��dwi
        imas = dir([folders(i).name,'\SWU*\SMS4_DIFF_HARDI_0*\*IMA']);
        if numel(imas) ~= 138
            message = ['���Ա�� ',num2str(temp(i)), '��DTI�ļ�����������138������'];
            disp(message);
            theflag(i) = 0;
            text =[text;message];
        end
        
        % ��鱻��temp(i)��dwi��ͼ
        imas = dir([folders(i).name,'\SWU*\SMS4_FIELDMAP_HARDI_*\*IMA']);
        if numel(imas) ~= 228
            message = ['���Ա�� ',num2str(temp(i)), '��DTI��ͼ�ļ�����������228������'];
            disp(message);
            theflag(i) = 0;
            text =[text;message];
        end
    else
        message = ['���Ա�� ',num2str(temp(i)), '�μ�Ŀ¼�ļ�������������1������'];
        disp(message);
        theflag(i) = 0;
        text =[text;message];
    end
end
if sum(theflag) == numel(temp)
    message = '����Ӱ���ļ���Ŀ������,δ��������';
    disp(message);
    text =[text;message];
else
    message = '�����ļ���Ŀ������,�������ʾ���';
    disp(message);
    text =[text;message];
end
timeprint = datestr(datetime);
fname = [timeprint(1:12), 'Ӱ���ļ������Ϣ.txt'];
writecell(text, fname);
disp('�����Ϣ��д��Ŀ���ļ����£�����');
pause
% mcc -m checkMRI.m