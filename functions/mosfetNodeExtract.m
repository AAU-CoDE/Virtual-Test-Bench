function mosfetNodeList = mosfetNodeExtract(LTlibPath,mosfetFileName,mosfetModel)
% MOSFETNODEEXTRACT returns the line in the netlist which includes the connections/nodes of the SPICE model (.subckt model d s g etc)
% This is used to properly define the connections in the netlist
%
% INPUT: 
% LTlibPath: Path to directory where .lib file is stored (string)
% mosfetFileName:  Name of the Mosfet .lib file as stored in the directory
% (string)
% mosfetModel: Name of the Mosfet model inside the .lib model. Typically
% stated after the first .subckt statement. (string)

 %%
    libraryFile = readtable(append(LTlibPath,mosfetFileName,'.lib'),'FileType','text','NumHeaderLines',0);
    libraryFile = table2cell(libraryFile);
    modelLibText = libraryFile(:,1);

    for n = 1:numel(modelLibText)
      if contains(modelLibText(n),append(".subckt ",mosfetModel)) == 1 || contains(modelLibText(n),append(".SUBCKT ",mosfetModel)) == 1
          mosfetNodeListIdx = n;
          mosfetNodeList = modelLibText(mosfetNodeListIdx);
            % remove .subckt
            mosfetNodeList = replace(mosfetNodeList,".subckt ","");
            mosfetNodeList = replace(mosfetNodeList,".SUBCKT ","");
            % convert to string
            mosfetNodeList = char(mosfetNodeList);
            mosfetNodeList = replace(mosfetNodeList,mosfetModel,"");
            break
      end
    end
    
    if exist('mosfetNodeList','var') == 0
    mosfetNodeList = nan;
    end
end