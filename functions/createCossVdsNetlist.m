%%% Create/Update netlist for RdsonTestBench
function createCossVdsNetlist(fcoss,Vds,cossPath,netlistFilename,userDef)
    
% Run THE LINE BELOW if LTSpice Circuit is changed and copy/paste matnetlist
% netlist2code("RdsonTestBench.net",append(pwd,"\LTSpiceModelExtraction\Rdson"))

    netlist = [append(cossPath,netlistFilename)];
    ltspiceFilename = replace(netlist,'.net','.asc');

    % Mosfet Model
    mosfetPath = replace(append(userDef.LTlibPath,userDef.mosfetModel),'\','\\');
    % Mosfet Model Parse (Make as standalone function in the future)
   % .subckt port parse 
    if contains(userDef.mosfetModel,'G3R') == 1 % Encrypted, can't be parsed
         mosfet = append('XU2 ds s s s tj tj  ', replace(userDef.mosfetModel,'\','\\'));
    else
       mosfet = append('XU2 ds s s tj ', replace(userDef.mosfetModel,'\','\\')); 
       mosfet = append('XU2 ',userDef.mosfetNodeList,' ', replace(userDef.mosfetModel,'\','\\')); 
       mosfet = replace(mosfet,' d ',' ds ');
       mosfet = replace(mosfet,' g ',' s ');
       mosfet = replace(mosfet,' s1 ',' s ');
       mosfet = replace(mosfet,' s2 ',' s ');
       mosfet = replace(mosfet,' Tj ',' tj ');
       mosfet = replace(mosfet,' Tc ',' tj ');
    end

    % Netlist to be run
    cossTestBenchNetlist = ['* ' replace(netlist,'\','\\')  '\r\n' ...
        mosfet '\r\n '...
        'V1 tj 0 {Tj}\r\n                                                                                                                          ' ...
        'VDC ds 0 {Vds}\r\n                                                                                                                          ' ...
        'VAC s 0 SINE(0 {Vac} {f})\r\n                                                                                                            ' ...
        '.param Tj = 25\r\n                                                                                                                          ' ...
        '.tran 0 {tsim} 0 1n\r\n                                                                                                                     ' ...
        '.param Vds = ' num2str(Vds) '\r\n                                                                                                                       ' ...
        '.param Vac = 25m\r\n                                                                                                                        ' ...
        '.lib ' mosfetPath '.lib\r\n  ' ...
        '.param f = ' num2str(fcoss) '\r\n                                                                                                                         ' ...
        '.param tsim = {2/f}\r\n                                                                                                                     ' ...
        '.backanno\r\n                                                                                                                               ' ...
        '.end\r\n                                                                                                                                    ' ...
                            ];
    
    %%% Save .net file
    fid = fopen(netlist, 'w+');
    fprintf(fid,cossTestBenchNetlist);
    fid = fclose(fid);


end
