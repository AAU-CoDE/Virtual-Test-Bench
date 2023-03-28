function cossExtracted = cossVdsExtraction(fcoss,VdsLims,nSampleTot,userDef);

%
% COSSVDSEXTRACTION returns the  non-linear drain-source voltage dependent output
% capacitance from a device's LTSpice model. It creates an LTSpice
% netlist and sweeps through the predefined values.
%
% INPUTS:
%
% fcoss: AC excitation voltage frequency, at which  Coss(Vds) is to be extracted.
%
% VdsLims: Drain-source voltage range, which is to be swept. In the format
% of [VdsMin, VdsMax]. If only VdsMax is provided, VdsMin is set to 1mV by
% default.
%
% nSampleTot: Number of LTSpice Samples (influences run-time)
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
%
% userDef.mosfetFileName: Name of the Mosfet .lib file as stored in the
% directory.
%
% userDef.mosfetModel: Name of the device. The relevant LTSpice .lib model
% should be stored as 'mosfetModel.lib'
%
% userDef.mosfetNodeList: The node list of the LTSpice model. Can change
% depending on model complexity.

    % Some Context
    disp("Coss(vds) extraction started")
    % Drain-Source Voltage Range
    VdsLimsLength = length(VdsLims);
    switch VdsLimsLength
        case  1       
            VdsMin = 1e3;
            VdsMax = VdsLims(1);
        case 2
            VdsMin = VdsLims(1);
            VdsMax = VdsLims(2);
        otherwise
            disp('Invalid drain-source voltage range provided. Default 1mv - 650V is set')
            VdsMin = 1e-3;
            VdsMax = 650;
    end
    % Based on these values, the voltage sample array is created with log-spacing in the low voltage range to capture the non-linearity 
    % First few samples (20%) should be in log (up to 1% of Vds Max)
    nSampleLog = ceil(nSampleTot*0.20);
    Vds_arrayLV = logspace(log10(VdsMin),log10(VdsMax*0.01),nSampleLog); % "low" voltage sample points
    
    % Last half of sample points should be linearily spaced
    Vds_arrayHV = linspace(VdsMax*0.01,VdsMax,nSampleTot-nSampleLog); % "high" voltage sample points
    Vds_array = [Vds_arrayLV, Vds_arrayHV(2:end)]; % combine drain-source voltage sample points
    
    % Set Coss path
    cossPath = append(userDef.pathName,'Coss\');
    ltFilename = 'cossTestBench';
    netlistFilename = append(ltFilename,'.net');
    cossBatchPath = replace(cossPath,'\','\\'); % Batch file needs double backslash
    
    % Write .bat file
    batchFileName = "cossLTspiceCall.bat";
    rdsonBatchFile = ['start "LTSpice" "' userDef.LTexePathBatch '" -b "' append(cossBatchPath,netlistFilename) '" -alt'];
    
    fidBatch = fopen(append(cossPath,batchFileName), 'w+');
    fprintf(fidBatch,rdsonBatchFile);
    fidBatch = fclose(fidBatch);
    
     % Sweep Vds values
    reltolvds = 1e-3;
    for sweepNr = 1:numel(Vds_array)
       Vds = Vds_array(sweepNr);
       % Write netlist with updated parameters
        createCossVdsNetlist(fcoss,Vds,cossBatchPath,netlistFilename,userDef)
        % Run LTSpice/Call batch file
        [status,cmdout] = dos(append(cossPath,'cossLTspiceCall.bat'));        
        % Extract Data
        simStart = 0;
        while simStart == 0
            pause(0.5)
            % Read .raw file for the first time
            try
               rawData(sweepNr) = LTspice2Matlab(append(cossPath,ltFilename,'.raw'));
            catch
                pause(5)
                rawData(sweepNr) = LTspice2Matlab(append(cossPath,ltFilename,'.raw'));
            end
            % Check whether simulation has started (by checking Vds)
            VdsSim = LTretrieve("V(ds)",rawData(sweepNr));
            if sweepNr > 1
                VdsTest =  Vds_array(sweepNr-1);
            else 
                VdsTest = 0;
            end
            if VdsSim > VdsTest
                simStart = 1;
            end
        end
        % Check whether simulation is done 
        while rawData(sweepNr).time_vect(end) < 2/fcoss
            pause(0.5)
            rawData(sweepNr) = LTspice2Matlab(append(cossPath,ltFilename,'.raw'));
        end
 
        % Extract Variables    
        if contains(userDef.mosfetModel,'G3R') == 1 % Encrypted, can't be parsed
           IacFull = LTretrieve("Ix(u2:DP)",rawData(sweepNr));
        else
            IacFull = LTretrieve("I(Vac)",rawData(sweepNr));
        end        
        VacFull = LTretrieve("V(s)",rawData(sweepNr));
        tFull = rawData(sweepNr).time_vect;
        % Remove first Period:
        firstPeriodIdx = find(tFull > 1e-6,1);
        t = tFull(firstPeriodIdx:end);
        Vac = VacFull(firstPeriodIdx:end);
        Iac = IacFull(firstPeriodIdx:end);

        % Find Coss 
        ts = 1/fcoss; % Time Period
        % Find time & value of max(Vac)
        [VacMax, VacMaxIdx] = max(Vac);
        tVacMax = t(VacMaxIdx);

        % Find time & value of min/max(Iac)
        [IacMax, IacMaxIdx] = max(Iac);
        IacMin = min(Iac);      
        tIacMax = t(IacMaxIdx);
        % Remove Bias
        IacAmp = (IacMax - IacMin)/2;
        
        % Calculate angle between V & I
        phaseAngle = mod((tIacMax - tVacMax)/ts*2*pi,pi);
        %phaseAngle = pi/2;
        % Impedance
        Z = VacMax/IacAmp;
        Coss = 1/(cos(pi/2 - phaseAngle)*Z*2*pi*fcoss);


        % Build Struct
        cossExtracted.Coss(sweepNr) = Coss;
        cossExtracted.f(sweepNr) = 1/ts;
        cossExtracted.Vds(sweepNr) = Vds;
        cossExtracted.VacMax(sweepNr) = VacMax;
        cossExtracted.tVacMax(sweepNr) = tVacMax;
        
        
        cossExtracted.IacAmp(sweepNr) =  IacAmp;
        cossExtracted.tIacMax(sweepNr) = tIacMax;
      
        cossExtracted.phaseAngle(1,sweepNr) = phaseAngle;
        cossExtracted.phaseAngle(2,sweepNr) = rad2deg(phaseAngle);
        cossExtracted.ts(sweepNr) = ts;
%         % Vectors
%         cossIterVec(sweepNr).Iac = Iac;
%         cossIterVec(sweepNr).Vac = Vac;
%         cossIterVec(sweepNr).t = t;
        % Some Context
        disp(append("Coss(", sprintf('%.1f',Vds)," V): ", sprintf('%.1f',Coss*1e12), " pF"))
    end
        disp("Coss(vds) extraction finished")
end    