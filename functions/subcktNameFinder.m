function mosfetModel = subcktNameFinder(userDef)
    LTlibPath = userDef.LTlibPath;
    mosfetLibFileName = userDef.mosfetLibFileName;

      
    libraryFile = readtable(append(LTlibPath,mosfetLibFileName,'.lib'),'FileType','text','NumHeaderLines',0);
    libraryFile = table2cell(libraryFile);
    modelLibText = libraryFile(:,1);

    % Check whether predefined mosfetModel is part of .lib file:
    if isfield(userDef,'mosfetModel') == 1
       modelExistsInLib = sum(contains(modelLibText,['.subckt ',userDef.mosfetModel])) > 0 || sum(contains(modelLibText,['.SUBCKT ',userDef.mosfetModel])) > 0;
       if modelExistsInLib > 0
           mosfetModel = userDef.mosfetModel;
           return
       end
    end
    % 
    subcktCnt = 1;
    for n = 1:numel(modelLibText)
      if contains(modelLibText(n),".subckt ") == 1 || contains(modelLibText(n),".SUBCKT ")
          mosfetNodeListIdx = n;
          mosfetNodeList = modelLibText(mosfetNodeListIdx);
            % remove .subckt 
            mosfetNodeList = replace(mosfetNodeList,".subckt ","");
            mosfetNodeList = replace(mosfetNodeList,".SUBCKT ","");
            % convert to string
            mosfetNodeList = char(mosfetNodeList);
            % Remove everything after next space
            space = strfind(mosfetNodeList," ");
            mosfetFileList{subcktCnt,:} = mosfetNodeList(1:space(1)-1);
            subcktCnt = subcktCnt + 1;
      end
    end

    % Confirm
    if exist('mosfetNodeList','var') == 1  
        disp(" ")
        disp("Consider defining the desired model in the beginning of the script.")
        disp(" ")
        modelConfirmed = input(append('Please confirm: The device name to be extracted is: ',mosfetFileList{1,:}, ' [Y/N] (Press ENTER to confirm)'),"s" );

        if isempty(modelConfirmed)
            modelConfirmed = 'Y';
        end
        switch modelConfirmed
            case {'Y','y',1}
                mosfetModel = mosfetFileList{1,:};
            case {'N','n',0}                
                [deviceIdx, tf] = listdlg('PromptString',{'Select the device name from the list below:',''},'SelectionMode','single','ListString',mosfetFileList);
                mosfetModel = mosfetFileList(deviceIdx);
            otherwise 
               disp("Invalid Answer.");
        end   
        
    else 
        disp(" ")
        disp('Could not parse .lib file (might be encrypted). Confirm or enter the name of the device model')
        disp(" ")
        disp("Consider defining the desired model in the beginning of the script.")
        modelNameIsSame = input('Is the filename of the .lib file the same as the device model (e.g. G2R80MT18J)? [Y/N] (Press ENTER to confirm)',"s" );
        if isempty(modelNameIsSame)
            modelNameIsSame = 'Y';
        end
        switch modelNameIsSame
            case {'Y','y',1}
                mosfetModel = mosfetLibFileName;
            case {'N','n',0}
                mosfetModel = input('Manually enter the name of the device model (e.g. G2R80MT18J). (Press ENTER to confirm)',"s" );
            otherwise 
               disp("Invalid Answer.");
        end 
    disp("Consider defining the desired model in the beginning of the script.")
    end
end
