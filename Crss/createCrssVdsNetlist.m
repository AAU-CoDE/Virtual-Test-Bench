%%% Create/Update netlist for RdsonTestBench
function createCrssVdsNetlist(fcrss,Vds,crssPath,netlistFilename,userDef)
    
% Run THE LINE BELOW if LTSpice Circuit is changed and copy/paste matnetlist
% netlist2code("RdsonTestBench.net",append(pwd,"\LTSpiceModelExtraction\Rdson"))

    netlist = [append(crssPath,netlistFilename)];
    ltspiceFilename = replace(netlist,'.net','.asc');

    % Mosfet Model
    mosfetPath = replace(append(userDef.LTlibPath,userDef.mosfetLibFileName),'\','\\');
    % Mosfet Model Parse (Make as standalone function in the future)
   % .subckt port parse 
    if contains(userDef.mosfetModel,'G3R') == 1 % Encrypted, can't be parsed
         mosfet = append('XU2 drain gate source source tj tj  ', replace(userDef.mosfetModel,'\','\\'));
    else
       
       mosfet = append('XU2 ',userDef.nodeListGeneral,' ', replace(userDef.mosfetModel,'\','\\'));       
       mosfet = replace(mosfet,' source ',' 0 ');       
       mosfet = replace(mosfet,' ksource ',' 0 ');

    end

    % Netlist to be run
    crssTestBenchNetlist = ['* ' netlist  '\r\n' ...
        mosfet '\r\n '...
        'V1 tj 0 {Tj}\r\n                                                                                                                          ' ...
        'VDC drain 0 {Vds}\r\n                                                                                                                          ' ...
        'VAC gate 0 SINE(0 {Vac} {f})\r\n                                                                                                           ' ...
        '.param Tj = 25\r\n                                                                                                                          ' ...
        '.tran 0 {tsim} 0 1n\r\n                                                                                                                     ' ...
        '.param Vds = ' num2str(Vds) '\r\n                                                                                                                       ' ...
        '.param Vac = 25m\r\n                                                                                                                        ' ...
        '.lib ' mosfetPath '.lib\r\n  ' ...
        '.param f = ' num2str(fcrss) '\r\n                                                                                                                         ' ...
        '.param tsim = {2/f}\r\n                                                                                                                     ' ...
        '.backanno\r\n                                                                                                                               ' ...
        '.end\r\n                                                                                                                                    ' ...
                            ];
    
    %%% Save .net file
    
    fidFailCount = 0;
    for fidFailCount = 1:5
        try
            fid = fopen(netlist, 'w+');
            fprintf(fid,crssTestBenchNetlist);
            fid = fclose(fid);
            break
        catch
            if fidFailCount == 5
                disp("Netlist manipulation failed.")
            end
        end
    end


end
