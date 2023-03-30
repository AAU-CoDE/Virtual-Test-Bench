function  [mosfetLibFileName, LTlibPath] = setSpiceLibPath(mosfetLibFileName)
% SETSPICELIBPATH checks whether the defined .lib file has a matching path.
% If not, a dialogue will open to select the correct path

    % Check whether pathfile already exists
    try
         load('LTlibPathInfo.mat','LTlibPath');
    catch
        % Set LTSPice library path (where you stored .lib files)
        % userDef.LTlibPath = 'C:\Users\gd48aa\OneDrive - Aalborg Universitet\Documents\LTspiceXVII\lib\SicMOSFET\Wolfspeed\';
        disp('Set LTSPice library path (where you store your .lib files)')
        LTlibPath = uigetdir('Set LTSPice library path'); 
        LTlibPath = append(LTlibPath,'\');
        save('LTlibPathInfo.mat','LTlibPath')
    end
    
    % Check if .lib file exists within defined path;
    if isfile([LTlibPath,mosfetLibFileName,'.lib']) == 0
        disp(['The defined .lib file (', mosfetLibFileName, '.lib) is not found in the defined path.',newline,'Please select the location of the .lib file.'])
        [mosfetLibFileName_, LTlibPath] = uigetfile('*.lib','Select the .lib file of the LTSpice model to be extracted.');
        mosfetLibFileName = replace(mosfetLibFileName_,'.lib','');
        save('LTlibPathInfo.mat','LTlibPath')
    end


 end