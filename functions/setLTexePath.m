function LTexePathBatch = setLTexePath()

    try
        load('LTexePathInfo.mat','LTexeFullPath')
    catch
        % Set LTSpice .exe path (where the application is installed - used for batch file generation)
        %LTexePath = 'C:\Program Files\LTC\LTspiceXVII\XVIIx86.exe';
        
        disp('Set LTSpice .exe path (where the application is installed - used for batch file generation)')
        [LTexeFile, LTexePath] = uigetfile('*.exe','Set LTSpice .exe path (XVIIx86.exe or similar)','C:\');
        LTexeFullPath = append(LTexePath,LTexeFile);
        save('LTexePathInfo.mat','LTexeFullPath')
    end

    LTexePathBatch = replace(LTexeFullPath,'\','\\');
end