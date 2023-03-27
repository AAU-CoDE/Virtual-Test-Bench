function mosfetModel = subcktNameFinder(LTlibPath,mosfetFileName)

    libraryFile = readtable(append(LTlibPath,mosfetFileName,'.lib'),'FileType','text','NumHeaderLines',0);
    libraryFile = table2cell(libraryFile);
    modelLibText = libraryFile(:,1);

    for n = 1:numel(modelLibText)
      if contains(modelLibText(n),".subckt ") == 1
          mosfetNodeListIdx = n;
          mosfetNodeList = modelLibText(mosfetNodeListIdx);
            % remove .subckt 
            mosfetNodeList = replace(mosfetNodeList,".subckt ","");
            % convert to string
            mosfetNodeList = char(mosfetNodeList);
            % Remove everything after next space
            space = strfind(mosfetNodeList," ");
            mosfetModel = mosfetNodeList(1:space(1)-1);
            break
      end
    end
    if exist('mosfetNodeList','var') == 0
        disp('Could not parse .lib file (might be encrypted). Confirm or enter the name of the device model')
        disp(" ")
        modelNameIsSame = input('Is the filename of the .lib file the same as the device model (e.g. G2R80MT18J)? [Y/N] (Press ENTER to confirm)',"s" );
        if isempty(modelNameIsSame)
            modelNameIsSame = 'Y';
        end
        switch modelNameIsSame
            case {'Y','y',0}
                mosfetModel = mosfetFileName;
            case {'N','n',1}
                mosfetModel = input('Manually enter the name of the device model (e.g. G2R80MT18J). (Press ENTER to confirm)',"s" );
            otherwise 
               disp("Invalid Answer.");
        end   
    end
end
