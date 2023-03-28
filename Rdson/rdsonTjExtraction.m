%%% Function to Extract Rdson(Tj) of a device Spice model
function rdsonExtracted = rdsonTjExtraction(Id,Vgs,Tj_array,userDef)
%
% RDSONTJEXTRACTION returns the junction temperature dependent static
% on-resistance values from a device's LTSpice model. It creates an LTSpice
% netlist and sweeps through the prefedined values.
%
% INPUTS:
%
% Id: Drain current, at which  Rdson(Tj) is to be extracted.
%
% Vgs: Gate-source voltage, at which Rdson(Tj) is to be extracted.
%
% Tj: Vector of junction temperatures to be swept.
%
% userDef: Structure that includes user-defined information about the relevant
% directories, the device model name, and the node list of the device.
% 
% userDef.pathName: Path to virtual test bench folder
%
% userDef.LTLibPath: Path to LTSpice Library, where device model is stored
%
% userDef.LTexePathBatch: Path to the .exe file of LTSpice, with double
% backslashes 
%
% userDef.mosfetFileName: Name of the Mosfet .lib file as stored in the
% directory.
%
% userDef.mosfetModel: Name of the device. The relevant LTSpice .lib model
% should be stored as 'mosfetModel.lib'
%
% userDef.mosfetNodeList: The node list of the LTSpice model. Can change
% depending on model complexity.
%
% In future version, it will be extended to be able to sweep Id & Vgs as
% well.
    % Some Context
    disp("Rdson(Tj) extraction started")
    
    % Set Rdson path
    rdsonPath = append(userDef.pathName,'Rdson\');
    ltFilename = 'RdsonTestBench';
    netlistFilename = append(ltFilename,'.net');
    rdsonBatchPath = replace(rdsonPath,'\','\\'); % Batch file needs double backslash
    
    % Write .bat file
    batchFileName = "rdsonLTspiceCall.bat";
    rdsonBatchFile = ['start "LTSpice" "' userDef.LTexePathBatch '" -b "' append(rdsonBatchPath,netlistFilename) '" -alt'];
    
    fidBatch = fopen(append(rdsonPath,batchFileName), 'w+');
    fprintf(fidBatch,rdsonBatchFile);
    fidBatch = fclose(fidBatch);
    
    reltoltj = 1e-1;
    % Sweep Tj values
    for sweepNr = 1:numel(Tj_array)
        Tj = Tj_array(sweepNr); % [degC]
    
        % Write netlist with updated parameters
        createRdsonTjNetlist(Id,Vgs,Tj,rdsonBatchPath,netlistFilename,userDef)
        % Run LTSpice/Call batch file
       [status,cmdout] =  dos(append(rdsonPath,'rdsonLTspiceCall.bat'));

        % Extract Data
        simStart = 0;
        while simStart == 0
            pause(0.5)
            % Read .raw file for the first time
            try
               rawData(sweepNr) = LTspice2Matlab(append(rdsonPath,ltFilename,'.raw'));
            catch
                pause(1)
                 rawData(sweepNr) = LTspice2Matlab(append(rdsonPath,ltFilename,'.raw'));
            end
            % Check whether simulation has started (by checking Tj)
            TjSim = LTretrieve("V(tj)", rawData(sweepNr));
            if abs(TjSim(1) - Tj)/TjSim(1) < reltoltj
                simStart = 1;

            end
        end
        % Check whether simulation is done 
        while  rawData(sweepNr).time_vect(end) < 10e-9
            % Extract Data
            pause(0.5)
            rawData(sweepNr) = LTspice2Matlab(append(rdsonPath,ltFilename,'.raw'));
        end
        
        % Extract Variables    
        Rdson = LTretrieve("V(rdson)",rawData(sweepNr));
       
        % Build Struct
        rdsonExtracted.Rdson(sweepNr) = Rdson(end);
        rdsonExtracted.Id(sweepNr) = Id;
        rdsonExtracted.Vgs(sweepNr) = Vgs;
        rdsonExtracted.Tj(sweepNr) = Tj;
        % Some Context
        disp(append("Rdson(", sprintf('%.1f',Tj)," degC): ", sprintf('%.1f',Rdson(end)*1e3), " mΩ"))
    end
        disp("Rdson(Tj) extraction finished")
end