rdsonPath = append(pathName,'\virtualTestBench\Rdson\');    
for itNr = 1:numel(Tj_array)
        Tj = Tj_array(itNr) % degC
        % Create Netlist
        run('rdsonNetlist.m')
        % Run Netlist.        
        dos(append(rdsonPath,'LTspice_call.bat'));
        % Extract Data
        pause(4)
        rawData(itNr) = LTspice2Matlab(append(rdsonPath,filename,'.raw'));
        % End LTSpice
        % dos(append(pwd,path,'LTspice_end.bat'))
        
        % Extract Variables    
        Rdson = LTretrieve("V(rdson)",rawData(itNr))
       
        % Build Struct
        rdsonIter.Rdson(itNr) = Rdson(end);
        rdsonIter.Id(itNr) = Id;
        rdsonIter.Vgs(itNr) = Vgs;
        rdsonIter.Tj(itNr) = Tj;
end