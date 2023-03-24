%%% Create/Update netlist for RdsonTestBench
function createRdsonTjNetlist(Id,Vgs,Tj,rdsonPath,netlistFilename,userDef)
    
% Run THE LINE BELOW if LTSpice Circuit is changed and copy/paste matnetlist
% netlist2code("RdsonTestBench.net",append(pwd,"\LTSpiceModelExtraction\Rdson"))

    netlist = [append(rdsonPath,netlistFilename)];
    ltspiceFilename = replace(netlist,'.net','.asc');

    % Mosfet Model
    mosfetPath = replace(append(userDef.LTlibPath,userDef.mosfetModel),'\','\\');
    % Mosfet Model Parse
    if contains(userDef.mosfetModel,'G3R') == 1 % Encrypted, can't be parsed
     mosfet = append('XU2 ds g 0 tj tj 0 ', replace(userDef.mosfetModel,'\','\\'));
    else
       mosfet = append('XU2 ',userDef.mosfetNodeList,' ', replace(userDef.mosfetModel,'\','\\')); 
       mosfet = replace(mosfet,' d ',' ds ');
       mosfet = replace(mosfet,' s ',' 0 ');
       mosfet = replace(mosfet,' s1 ',' 0 ');
       mosfet = replace(mosfet,' s2 ',' 0 ');
       mosfet = replace(mosfet,' Tj ',' tj ');
       mosfet = replace(mosfet,' Tc ',' tj '); 
    end

    % Netlist to be run
    rdsonTestBenchNetlist = ['* ' replace(netlist,'\','\\')  '\r\n' ...
    'L1 0 ds 120\r\n  ' ...
    mosfet '\r\n '...
    'V2 tj 0 {Tj}\r\n  ' ...
    'V1 g 0 ' num2str(Vgs) '\r\n  ' ...
    'B1 Rdson 0 V=V(ds)/{id}\r\n ' ...
    '.ic I(L1) = {id}\r\n  ' ...
    '.lib ' mosfetPath '.lib\r\n  ' ...
    '.param id = ' num2str(Id) '\r\n ' ...
    '.param Tj = ' num2str(Tj) '\r\n ' ...
    '.tran 0 10n 0 0.1n\r\n  ' ...
    '.meas Rdson FIND V(Rdson) AT 10ns\r\n ' ...
    '.backanno\r\n ' ...
    '.end\r\n  ' ...
    ];
    
    %%% Save .net file
    fid = fopen(netlist, 'w+');
    fprintf(fid,rdsonTestBenchNetlist);
    fid = fclose(fid);


end
