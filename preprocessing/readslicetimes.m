function stimes = readslicetimes(filename)
    val = jsondecode(fileread(filename));
    stimes = val.SliceTiming; % ��λ����
    stimes = stimes * 1000;
end