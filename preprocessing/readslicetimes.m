function stimes = readslicetimes(filename)
    val = jsondecode(fileread(filename));
    stimes = val.SliceTiming; % µ•Œª «√Î
    stimes = stimes * 1000;
end