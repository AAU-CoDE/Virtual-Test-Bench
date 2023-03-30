function pathName = setWorkingDir()

    fullFilePath =  matlab.desktop.editor.getActiveFilename;
    startOfFileName = find(fullFilePath == '\',1,"last");
    pathName = fullFilePath(1:startOfFileName);
    % Add relevant folders to path
    cd(pathName)
    addpath(genpath(pathName))

end